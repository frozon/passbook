# this was added for testability because I couldn't figure out something better.
class CommandUtils
  def self.get_assets(directory)
    Dir[File.join(directory, '*')]
  end
  
  def self.get_current_directory
    File.dirname(__FILE__)
  end
end


