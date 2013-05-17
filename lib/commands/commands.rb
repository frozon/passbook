$:.push File.expand_path('../', __FILE__)

require 'commands/build'
require 'commands/generate'
#require 'commands/serve'
private

def determine_directory!
  files = Dir['*/pass.json']
  @directory ||= case files.length
                 when 0 then nil
                 when 1 then File.dirname(files.first)
                 else
                   @directory = choose "Select a directory:", *files.collect{|f| File.dirname(f)}
                 end
end

def validate_directory!
  say_error "Missing argument" and abort if @directory.nil?
  say_error "Directory #{@directory} does not exist" and abort unless File.directory?(@directory)
  say_error "Directory #{@directory} is not a valid pass" and abort unless File.exist?(File.join(@directory, "pass.json"))
end

def validate_certificate!
  say_error "Missing or invalid certificate file" and abort if @certificate.nil? or not File.exist?(@certificate) 
end
