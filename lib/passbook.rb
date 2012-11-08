require "passbook/version"
require "passbook/pkpass"
require 'active_support/core_ext/module/attribute_accessors'

module Passbook
  mattr_accessor :p12_cert, :p12_password, :wwdc_cert, :p12_certificate, :p12_key

  def self.configure
    yield self
  end
end
