require "passbook/version"
require "passbook/pkpass"
require 'active_support/core_ext/module/attribute_accessors'
require 'passbook/push_notification'

module Passbook
  mattr_accessor :p12_cert, :p12_password, :wwdc_cert, :p12_certificate, :p12_key, :notification_cert

  def self.configure
    yield self
  end
end
