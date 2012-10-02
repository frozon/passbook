module Passbook
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      argument :wwdc_cert_path, type: :string, default: '', optional: true, banner: "Absolute path to your wwdc cert file"
      argument :p12_cert_path, type: :string, default: '', optional: true, banner: "Absolute path to your cert.p12 file"
      argument :p12_password, type: :string, default: '', optional: true, banner: "Password for your certificate"

      desc 'Create passbook initializer'
      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'passbook.rb')
      end
    end
  end
end
