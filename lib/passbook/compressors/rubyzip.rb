require 'passbook/compressors/base'
require 'zip'

module Passbook
  module Compressor

    class Rubyzip < Base

      ###
      # Human-readable name of the compressors
      #
      def name
        "RubyZip"
      end

      ###
      # Output zip string
      #
      def outputZip pass, files, manifest, signature
        Zip::OutputStream.write_buffer do |zip|
          zip.put_next_entry 'pass.json'
          zip.write pass
          zip.put_next_entry 'manifest.json'
          zip.write manifest
          zip.put_next_entry 'signature'
          zip.write signature

          files.each do |file|
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
end