require 'lib/commands/commands_spec_helper'
require 'passbook'

describe 'Build' do

  before :each do
    $stderr = StringIO.new
    mock_terminal
  end

  context 'missing or incorect options' do
    specify 'missing directory' do
      begin
        lambda {
          run 'build'
        }.should raise_error(SystemExit, ' ')

      rescue
        @output.string.should eq "\e[31mMissing argument\e[0m\n"
      end
    end

    specify 'good directory,  no certificate file' do
      File.should_receive(:directory?).with('scraps').and_return true
      File.should_receive(:exist?).once.with('scraps/pass.json').and_return true
      File.should_receive(:exist?).once.with('scraps.pkpass').and_return false

      begin
        lambda {
          run('build', 'scraps')
        }.should raise_error(SystemExit, '  ')
      rescue
        @output.string.should eq "\e[31mMissing or invalid certificate file\e[0m\n"
      end
    end

    specify 'good directory,  and certificate file' do
      File.should_receive(:directory?).with('scraps').and_return true
      File.should_receive(:exist?).once.with('scraps/pass.json').and_return true
      File.should_receive(:exist?).once.with('scraps.pkpass').and_return false
      File.should_receive(:exist?).with('jackels').and_return true

      run_failing_command 'build', 'scraps', '-w', 'jackels' do
        @output.string.should eq "Enter certificate password:\n\n"
      end    
    end
  end

  def run_failing_command(*args, &block)
    begin
      lambda{
        run(*args)
      }.should raise_error(SystemExit, ' ')
    rescue
      yield
    end
  end
end
