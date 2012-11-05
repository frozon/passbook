source 'https://rubygems.org'

# Specify your gem's dependencies in passbook.gemspec
#gemspec
gem 'rubyzip'

platforms :jruby do
  gem 'jruby-openssl'
end

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
end

group :test, :development do
  gem 'activesupport'
  gem 'jeweler'
  gem 'simplecov'
  gem 'rspec'
  gem 'rake' 
  gem 'yard'
end
