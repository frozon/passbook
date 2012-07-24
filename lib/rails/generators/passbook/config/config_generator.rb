module Passbook
  module Generators
    class ConfigGenerator < Rails::Generators::Base
       def self.source_root
          @_passbook_source_root ||= File.expand_path("../templates", __FILE__)
      end

      desc 'Create passbook initializer'
      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'passbook.rb')
      end
    end
  end
end
