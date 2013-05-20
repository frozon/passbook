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


  end


end

