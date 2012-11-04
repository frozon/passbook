require 'rubygems'
require 'bundler'
require 'json'
require 'simplecov'
SimpleCov.start

# stubbing out rails generators.
module Rails
  module Generators
    class Base
      def self.source_root arg
      end

      def self.argument arg, args
      end

      def self.desc arg
      end
    end
  end
end

Dir['lib/**/*.rb'].each {|f| require File.join(File.dirname(__FILE__), '..', f.gsub(/.rb/, ''))}
