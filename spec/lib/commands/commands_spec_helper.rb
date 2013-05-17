require 'spec_helper'
require 'terminal-table'
require 'commander/import'

Dir['lib/commands/**/*.rb'].each {|f| require File.join(File.dirname(__FILE__), '../../..', f.gsub(/.rb/, ''))}

def mock_terminal
  @input = StringIO.new
  @output = StringIO.new
  $terminal = HighLine.new @input, @output
end

def new_command_runner *args, &block
  Commander::Runner.instance_variable_set :"@singleton", Commander::Runner.new(args)
  program :name, 'test'
  program :version, '1.2.3'
  program :description, 'something'
  create_test_command
  yield if block
  Commander::Runner.instance
end

def run *args
  new_command_runner(*args) do
    program :help_formatter, Commander::HelpFormatter::Base
  end.run!    
  @output.string
end

RSpec::Matchers.define :exit_with_code do |exp_code|
  actual = nil
  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual and actual == exp_code
  end
  failure_message_for_should do |block|
    "expected block to call exit(#{exp_code}) but exit" +
      (actual.nil? ? " not called" : "(#{actual}) was called")
  end
  failure_message_for_should_not do |block|
    "expected block not to call exit(#{exp_code})"
  end
  description do
    "expect block to call exit(#{exp_code})"
  end
end

