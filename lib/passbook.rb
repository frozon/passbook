require "passbook/version"
require "passbook/pkpass"

module Passbook
  mattr_accessor :p12_cert, :p12_password

  def self.configure
    yield self
  end
end
