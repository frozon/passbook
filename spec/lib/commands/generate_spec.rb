require 'lib/commands/commands_spec_helper'
require 'passbook'

describe 'Generate' do

  before :each do
    $stderr = StringIO.new
    mock_terminal
  end

  context 'command' do
    specify 'no options' do
      run_command 'generate' do
        @output.string.should eq 'Enter a passbook name: '
      end

    end

    specify 'passbook entered directory already exists' do
      @input << "my_awesome_passbook\n"
      @input.rewind
      File.should_receive(:directory?).with('my_awesome_passbook').and_return true
      run_command 'generate' do
        @output.string.should eq "Enter a passbook name: \e[31mDirectory my_awesome_passbook already exists\e[0m\n"
      end    
    end

    specify 'passbook entered file already exists' do
      @input << "my_awesome_passbook\n"
      @input.rewind
      File.should_receive(:directory?).with('my_awesome_passbook').and_return false
      File.should_receive(:exist?).with('my_awesome_passbook').and_return true
      run_command 'generate' do
        @output.string.should eq "Enter a passbook name: \e[31mFile exists at my_awesome_passbook\e[0m\n"
      end    
    end

    context 'valid pass directory' do
      
      before :each do
        File.should_receive(:directory?).with('my_awesome_passbook').and_return false
        File.should_receive(:exist?).with('my_awesome_passbook').and_return false
      end

      specify 'invalid type' do
        @input << "my_awesome_passbook\n"
        @input.rewind
        run_command 'generate', '-T', 'honey_badger' do
          @output.string.should eq "Enter a passbook name: \e[31mInvalid type: \"honey_badger\", expected one of: [boarding-pass, coupon, event-ticket, store-card, generic]\e[0m\n"
        end    
      end

      specify 'valid type' do
        CommandUtils.should_receive(:get_current_directory).and_return('')
        FileUtils.should_receive(:mkdir_p).with('my_awesome_passbook')
        FileUtils.should_receive(:cp).with("/../commands/templates/boarding-pass.json", "my_awesome_passbook/pass.json")
        FileUtils.should_receive(:touch).with("my_awesome_passbook/icon.png")
        FileUtils.should_receive(:touch).with("my_awesome_passbook/icon@2x.png")
        @input << "1\n"
        @input.rewind
        run_command 'generate', 'my_awesome_passbook'  do
          @output.string.should eq "Select a pass type\n1. boarding-pass\n2. coupon\n3. event-ticket\n4. store-card\n5. generic\n?  \e[32mPass generated in my_awesome_passbook\e[0m\n"
        end    
      end
    end

    pending 'good directory' do

      before :each do
        File.should_receive(:directory?).with('scraps').and_return true
        File.should_receive(:exist?).once.with('scraps/pass.json').and_return true
        File.should_receive(:exist?).once.with('scraps.pkpass').and_return false
      end

      specify 'no certificate file' do
        begin
          lambda {
            run('build', 'scraps')
          }.should raise_error(SystemExit, '  ')
        rescue
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

