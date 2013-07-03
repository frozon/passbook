require 'digest/sha1'
require 'openssl'
require 'zip/zip'
require 'base64'

module Passbook
  class PKPass
    attr_accessor :pass, :manifest_files

    TYPES = ['boarding-pass', 'coupon', 'event-ticket', 'store-card', 'generic']

    # Require fields, meta programming for accessor
    REQUIRED_FIELDS = %w(passTypeIdentifier teamIdentifier serialNumber organizationName formatVersion description)
    REQUIRED_FIELDS.each do |accessor|
      class_eval %Q{
        def #{accessor}= value
          json = JSON.parse(@pass)
          json['#{accessor}'] = value
          @pass = json.to_json
        end
      }
    end

    def initialize pass
      @pass      = pass
      @manifest_files     = []
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
      temp_file.write self.stream.string
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
        key_hash[:key] = OpenSSL::PKey::RSA.new File.read(Passbook.p12_key), Passbook.p12_password
        key_hash[:cert] = OpenSSL::X509::Certificate.new File.read(Passbook.p12_certificate)
      else
        p12 = OpenSSL::PKCS12.new File.read(Passbook.p12_cert), Passbook.p12_password
        key_hash[:key], key_hash[:cert] = p12.key, p12.certificate
      end
      key_hash
    end

    def createSignature manifest
      p12   = get_p12_cert_and_key
      wwdc  = OpenSSL::X509::Certificate.new File.read(Passbook.wwdc_cert)
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
      REQUIRED_FIELDS.each do |require_field|
        raise "#{require_field} mising" unless @pass.include?(require_field)
      end
      # Specific test
      raise 'Format Version should be a numeric' unless JSON.parse(@pass)['formatVersion'].is_a?(Numeric)
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

      Zip::ZipOutputStream.write_buffer do |zip|
        zip.put_next_entry 'pass.json'
        zip.write @pass
        zip.put_next_entry 'manifest.json'
        zip.write manifest
        zip.put_next_entry 'signature'
        zip.write signature

        @manifest_files.each do |file|
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
