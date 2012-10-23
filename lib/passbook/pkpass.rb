require 'digest/sha1'
require 'openssl'
require 'zip/zip'
require 'base64'

module Passbook
  class PKPass

    def initialize json
      @json      = json
      @files     = []
    end

    def addFile file
      @files << file
    end

    def addFiles files
      @files += files
    end

    def json= json
      @json = json
    end

    def build
      manifest = self.createManifest

      # Check pass for necessary files and fields
      self.checkPass manifest

      # Create pass signature
      signature = self.createSignature manifest

      return [manifest, signature]
    end

    # Backward compatibility
    def create
      self.file.path
    end

    # Return a Tempfile containing our ZipStream
    def file(options = {})
      options[:file_name] ||= 'pass.pkpass'

      temp_file = Tempfile.new(options[:file_name])
      temp_file.write self.stream.string
      temp_file.close

      temp_file
    end

    # Return a ZipOutputStream
    def stream
      manifest, signature = self.build

      self.outputZip manifest, signature
    end

    protected

      def checkPass manifest
        # Check for default images
        raise 'Icon missing' unless manifest.include?('icon.png')
        raise 'Icon@2x missing' unless manifest.include?('icon@2x.png')
        raise 'Logo missing' unless manifest.include?('logo.png')
        raise 'Logo@2x missing' unless manifest.include?('logo@2x.png')

        # Check for developer field in JSON
        raise 'Pass Type Identifier missing' unless @json.include?('passTypeIdentifier')
        raise 'Team Identifier missing' unless @json.include?('teamIdentifier')
        raise 'Serial Number missing' unless @json.include?('serialNumber')
        raise 'Organization Name Identifier missing' unless @json.include?('organizationName')
        raise 'Format Version' unless @json.include?('formatVersion')
        raise 'Description' unless @json.include?('description')
      end

      def createManifest
        sha1s = {}
        sha1s['pass.json'] = Digest::SHA1.hexdigest @json

        @files.each do |file|
          if file.class == Hash
            sha1s[file[:name]] = Digest::SHA1.hexdigest file[:content]
          else
            sha1s[File.basename(file)] = Digest::SHA1.file(file).hexdigest
          end
        end

        return sha1s.to_json
      end

      def createSignature manifest
        p12   = OpenSSL::PKCS12.new File.read(Passbook.p12_cert), Passbook.p12_password
        wwdc  = OpenSSL::X509::Certificate.new File.read(Passbook.wwdc_cert)
        pk7   = OpenSSL::PKCS7.sign p12.certificate, p12.key, manifest.to_s, [wwdc], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
        data  = OpenSSL::PKCS7.write_smime pk7

        str_debut = "filename=\"smime.p7s\"\n\n"
        data = data[data.index(str_debut)+str_debut.length..data.length-1]
        str_end = "\n\n------"
        data = data[0..data.index(str_end)-1]

        return Base64.decode64(data)
      end

      def createZip manifest, signature
        t = Tempfile.new("pass.pkpass")

        zip_out = outputZip(manifest, signature)
        t.write zip_out.string
        path = t.path

        t.close
        return path
      end

      def outputZip manifest, signature

        Zip::ZipOutputStream.write_buffer do |zip|
          zip.put_next_entry 'pass.json'
          zip.write @json
          zip.put_next_entry 'manifest.json'
          zip.write manifest
          zip.put_next_entry 'signature'
          zip.write signature

          @files.each do |file|
            if file.class == Hash
              zip.put_next_entry file[:name]
              zip.print file[:content]
            else
              zip.put_next_entry File.basename(file)
              zip.print IO.read(file)
            end
          end
        end
      end
  end
end