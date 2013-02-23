#!/usr/bin/env rake
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "passbook"
  gem.homepage = "http://github.com/frozon/passbook"
  gem.license = "MIT"
  gem.summary = %Q{A IOS Passbook generator.}
  gem.description = %Q{This gem allows you to create IOS Passbooks.  Unlike some,  this works with Rails but does not require it.}
  gem.email = ['thomas@lauro.fr', 'lgleason@polyglotprogramminginc.com']
  gem.authors = ['Thomas Lauro', 'Lance Gleason']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
