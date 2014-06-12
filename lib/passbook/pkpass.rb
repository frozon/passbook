require 'digest/sha1'
require 'openssl'
require 'zipruby'
require 'base64'
require 'pry'

module Passbook
  class PKPass
    attr_accessor :pass, :manifest_files, :buf

    TYPES = ['boarding-pass', 'coupon', 'event-ticket', 'store-card', 'generic']

    def initialize pass
      $stdout.binmode
      @pass      = pass
      @manifest_files     = []
      @buf = StringIO.new
    end

    def addFile file
      @manifest_files << file
    end

    def addFiles files
      @manifest_files += files
    end

    # for backwards compatibility
    def json= json
      @pass = json
    end

    def build
      manifest = createManifest

      # Check pass for necessary files and fields
      checkPass manifest

      # Create pass signature
      signature = createSignature manifest

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
      temp_file.write @buf.to_s
      temp_file.close

      temp_file
    end

    # Return a ZipOutputStream
    def stream
      manifest, signature = build

      outputZip manifest, signature
    end

    def get_p12_cert_and_key
      key_hash = {}
      if Passbook.p12_key
        key_hash[:key] = OpenSSL::PKey::RSA.new Passbook.p12_key, Passbook.p12_password
        key_hash[:cert] = OpenSSL::X509::Certificate.new Passbook.p12_certificate
      else
        p12 = OpenSSL::PKCS12.new Passbook.p12_cert, Passbook.p12_password
        key_hash[:key], key_hash[:cert] = p12.key, p12.certificate
      end
      key_hash
    end

    def createSignature manifest
      p12   = get_p12_cert_and_key
      wwdc  = OpenSSL::X509::Certificate.new Passbook.wwdc_cert
      pk7   = OpenSSL::PKCS7.sign p12[:cert], p12[:key], manifest.to_s, [wwdc], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
      data  = OpenSSL::PKCS7.write_smime pk7

      str_debut = "filename=\"smime.p7s\"\n\n"
      data = data[data.index(str_debut)+str_debut.length..data.length-1]
      str_end = "\n\n------"
      data = data[0..data.index(str_end)-1]

      return Base64.decode64(data)
    end

    private

    def checkPass manifest
      # Check for default images
      raise 'Icon missing' unless manifest.include?('icon.png')
      raise 'Icon@2x missing' unless manifest.include?('icon@2x.png')

      # Check for developer field in JSON
      raise 'Pass Type Identifier missing' unless @pass.include?('passTypeIdentifier')
      raise 'Team Identifier missing' unless @pass.include?('teamIdentifier')
      raise 'Serial Number missing' unless @pass.include?('serialNumber')
      raise 'Organization Name Identifier missing' unless @pass.include?('organizationName')
      raise 'Format Version' unless @pass.include?('formatVersion')
      raise 'Format Version should be a numeric' unless JSON.parse(@pass)['formatVersion'].is_a?(Numeric)
      raise 'Description' unless @pass.include?('description')
    end

    def createManifest
      sha1s = {}
      sha1s['pass.json'] = Digest::SHA1.hexdigest @pass

      @manifest_files.each do |file|
        if file.class == Hash
          sha1s[file[:name]] = Digest::SHA1.hexdigest file[:content]
        else
          sha1s[File.basename(file)] = Digest::SHA1.file(file).hexdigest
        end
      end

      return sha1s.to_json
    end

    def outputZip manifest, signature
      buf = ''

      zip = Zip::Archive.open_buffer(buf, Zip::CREATE) do |zip|
        zip.add_buffer('pass.json', @pass)
        zip.add_buffer('manifest.json', manifest)
        zip.add_buffer('signature', signature)

        @manifest_files.each do |file|
          if file.class == Hash
            zip.add_buffer(file[:name], file[:content])
          else
            zip.add_buffer(File.basename(file), IO.read(file))
          end
        end
      end

      @buf.string = buf
      zip
    end
  end
end
