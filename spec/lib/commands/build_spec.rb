require 'lib/commands/commands_spec_helper'
require 'passbook'

describe 'Build' do

  before :each do
    $stderr = StringIO.new
    mock_terminal
  end

  context 'command' do
    specify 'missing directory' do
      run_command 'build' do
        @output.string.should eq "\e[31mMissing argument\e[0m\n"
      end
    end

    context 'good directory' do

      before :each do
        File.should_receive(:directory?).with('scraps').and_return true
        File.should_receive(:exist?).once.with('scraps/pass.json').and_return true
        File.should_receive(:exist?).once.with('scraps.pkpass').and_return false
      end

      specify 'no certificate file' do
        run_command 'build', 'scraps' do
          @output.string.should eq "\e[31mMissing or invalid certificate file\e[0m\n" 
        end
      end

      context 'good certificate file' do
        before :each do
          File.should_receive(:exist?).with('jackels').and_return true
        end

        specify 'no certificate password entered' do
          run_command 'build', 'scraps', '-w', 'jackels' do
            @output.string.should eq "Enter certificate password:\n\n"
          end    
        end

        context 'all required values' do

          let(:pass_json) {'{"this":"is awesome json"}'}
          let(:pass_assets) {['pass.json', 'something.jpeg']}

          before :each do
            Passbook.should_receive(:wwdc_cert=).with 'jackels'      
            Passbook.should_receive(:p12_key=).with 'badger_key'      
            Passbook.should_receive(:p12_certificate=).with 'badger_cert'      
            Passbook.should_receive(:p12_password=).with 'bees'    
            CommandUtils.should_receive(:get_assets).with('scraps').and_return pass_assets 
            @pk_pass = double 'pk pass'
            File.should_receive(:read).with('pass.json').and_return pass_json 
            Passbook::PKPass.should_receive(:new).with(pass_json).and_return @pk_pass
            @pk_pass.should_receive(:addFiles).with pass_assets
          end

          specify 'are set from command line' do
            pass_stream = double 'passbook stream' 
            pass_stream.should_receive(:string).and_return 'my badass pass'
            @pk_pass.should_receive(:stream).and_return pass_stream
            File.should_receive(:open).with('scraps.pkpass', 'w')

            run_command 'build', 'scraps', '-w', 'jackels',
              '-p', 'bees', '-k', 'badger_key', '-c', 'badger_cert' do
              @output.string.should eq ""
              end    
          end

          specify 'should catch a general error' do
            @pk_pass.should_receive(:stream).and_raise(StandardError.new('I have failed'))
            run_command 'build', 'scraps', '-w', 'jackels',
              '-p', 'bees', '-k', 'badger_key', '-c', 'badger_cert' do
              @output.string.should eq "\e[31mError: I have failed\e[0m\n"
              end    
          end

          specify 'should catch a general error' do
            @pk_pass.should_receive(:stream).and_raise(OpenSSL::PKCS12::PKCS12Error.new('I am a failure'))
            run_command 'build', 'scraps', '-w', 'jackels',
              '-p', 'bees', '-k', 'badger_key', '-c', 'badger_cert' do
              @output.string.should eq "\e[31mError: I am a failure\e[0m\n\e[33mYou may be getting this error because the certificate password is either incorrect or missing\e[0m\n"
              end    
          end
        end
      end
    end
  end

end
