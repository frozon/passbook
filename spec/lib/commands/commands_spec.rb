require 'lib/commands/commands_spec_helper'

describe 'Commands' do

  before :each do
    program :version, '1.2.3'
    program :description, "Honey Badger Don't Care"
  end

  context 'determine directory' do

    specify 'no directories' do
      Dir.should_receive(:[]).and_return []
      determine_directory!
      @directory.should eq nil
    end

    specify 'one directory present' do
      Dir.should_receive(:[]).and_return ['ass']
      File.should_receive(:dirname).with('ass').and_return('/honey/badger/is/bad/ass')
      determine_directory!
      @directory.should eq '/honey/badger/is/bad/ass'
    end

    specify 'multiple directories' do
      Dir.should_receive(:[]).and_return ['cobras', 'bee_larvae']
      File.should_receive(:dirname).with('cobras').and_return('/yummy/cobras')
      File.should_receive(:dirname).with('bee_larvae').and_return('/disgusting/bee_larvae')
      self.should_receive(:choose).with('Select a directory:', 
                                        '/yummy/cobras', '/disgusting/bee_larvae').and_return '/yummy/cobras'
      determine_directory!
      @directory.should eq '/yummy/cobras' 
    end

  end

  context 'validate directory' do

    specify 'missing directory' do
      self.should_receive(:say_error).with('Missing argument').and_return true
      lambda {
        @directory = nil
        validate_directory!
      }.should exit_with_code(1)
    end

    specify 'directory does not exist' do
      self.should_receive(:say_error).with("Directory scraps does not exist").and_return true
      File.should_receive(:directory?).with('scraps').and_return false
      lambda {
        @directory = 'scraps'
        validate_directory!
      }.should exit_with_code(1) 
    end

    specify 'directory does not have a valid pass' do
      self.should_receive(:say_error).with("Directory scraps is not a valid pass").and_return true
      File.should_receive(:directory?).with('scraps').and_return true
      File.should_receive(:exist?).with('scraps/pass.json').and_return false
      lambda {
        @directory = 'scraps'
        validate_directory!
      }.should exit_with_code(1) 
    end

    specify 'directory has valid pass' do
      File.should_receive(:directory?).with('scraps').and_return true
      File.should_receive(:exist?).with('scraps/pass.json').and_return true
      lambda {
        @directory = 'scraps'
        validate_directory!
      }.should_not exit_with_code(1) 
    end
  end

  context 'validate certificate' do
    specify 'nil certificate' do
      self.should_receive(:say_error).with("Missing or invalid certificate file").and_return true
      lambda {
        @certificate = nil
        validate_certificate!
      }.should exit_with_code(1) 
    end

    specify 'certificate file does not exist' do
      self.should_receive(:say_error).with("Missing or invalid certificate file").and_return true
      File.should_receive(:exist?).with('jackels').and_return false
      lambda {
        @certificate = 'jackels'
        validate_certificate!
      }.should exit_with_code(1) 
    end

    specify 'certificate file exists' do
      File.should_receive(:exist?).with('jackels').and_return true
      lambda {
        @certificate = 'jackels'
        validate_certificate!
      }.should_not exit_with_code(1) 
    end
  end 
end
