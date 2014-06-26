module Passbook
  module Compressor
    class Base

      def initialize
      end

      ###
      # Human-readable name of the compressors
      #
      def name
        fail
      end

      ###
      # Output zip string
      #
      def outputZip pass, files, manifest, signature
        fail
      end

    end
  end
end
