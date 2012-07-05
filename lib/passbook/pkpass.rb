require 'digest/sha1'
require 'OpenSSL'
require 'zip/zip'
require 'base64'

module Passbook
  class PKPass

    def initialize json
      @json      = json
      @files     = []
    end

    def addFile file_path
      @files << file_path
    end

    def json= json
      @json = json
    end

    def create
      manifest = self.createManifest
      signature = self.createSignature manifest

      return self.createZip(manifest, signature)
    end

    protected

      def createManifest
        sha1s = {}
        puts "JSON : #{@json}"
        sha1s['pass.json'] = Digest::SHA1.hexdigest @json

        @files.each do |file|
          sha1s[File.basename(file)] = Digest::SHA1.file(file).hexdigest
        end

        return sha1s.to_json
      end

      def createSignature manifest
        p12   = OpenSSL::PKCS12.new File.read(Passbook.p12_cert), Passbook.p12_password
        pk7   = OpenSSL::PKCS7.sign p12.certificate, p12.key, manifest.to_s, [], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
        data  = OpenSSL::PKCS7.write_smime pk7

        str_debut = "filename=\"smime.p7s\"\n\n"
        data = data[data.index(str_debut)+str_debut.length..data.length-1]
        str_end = "\n\n------"
        data = data[0..data.index(str_end)-1]

        return Base64.decode64(data)
      end

      def createZip manifest, signature
        t = Tempfile.new("pass.pkpass")

        Zip::ZipOutputStream.open(t.path) do |z|
          z.put_next_entry 'pass.json'
          z.print @json
          z.put_next_entry 'manifest.json'
          z.print manifest
          z.put_next_entry 'signature'
          z.print signature

          @files.each do |file|
            z.put_next_entry File.basename(file)
            z.print IO.read(file)
          end
        end
        path = t.path

        t.close
        return path
      end
  end
end