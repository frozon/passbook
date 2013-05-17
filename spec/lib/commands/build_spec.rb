require 'lib/commands/commands_spec_helper'

describe 'Build' do

  before :each do
    program :version, '1.2.3'
    program :description, "Honey Badger Don't Care"
    $stderr = StringIO.new
    mock_terminal
  end

  specify "" do
  end
end
