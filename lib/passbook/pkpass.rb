require 'digest/sha1'
require 'openssl'
require 'zip'
require 'base64'

module Passbook
  class PKPass
    attr_accessor :pass, :manifest_files, :signer

    TYPES = ['boarding-pass', 'coupon', 'event-ticket', 'store-card', 'generic']

    def initialize(pass, init_signer = nil)
      @pass           = pass
      @manifest_files = []
      @signer         = init_signer || Passbook::Signer.new
    end

    def addFile(file)
      @manifest_files << file
    end

    def addFiles(files)
      @manifest_files += files
    end

    # for backwards compatibility
    def json=(json)
      @pass = json
    end

    def build
      manifest = createManifest

      # Check pass for necessary files and fields
      checkPass manifest

      # Create pass signature
      signature = @signer.sign manifest

      [manifest, signature]
    end

    # Backward compatibility
    def create
      self.file.path
    end

    # Return a Tempfile containing our ZipStream
    def file(options = {})
      options[:file_name] ||= 'pass.pkpass'
      temp_file = Tempfile.new(options[:file_name])
      temp_file.binmode
      temp_file.write self.stream.string
      temp_file.close

      temp_file
    end

    # Return a ZipOutputStream
    def stream
      manifest, signature = build

      outputZip manifest, signature
    end

    private

    def checkPass(manifest)
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

      sha1s.to_json
    end

    def outputZip(manifest, signature)

      Zip::OutputStream.write_buffer do |zip|
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
