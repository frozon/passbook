require 'openssl'
require 'base64'

module Passbook
  class Signer
    def initialize certificate = nil, password = nil, key = nil, wwdc_cert = nil
      @certificate ||= Passbook.p12_certificate
      @password    ||= Passbook.p12_password
      @key         ||= Passbook.p12_key
      @wwdc_cert   ||= Passbook.wwdc_cert
      @key_hash      = compute_cert
    end

    def sign data
      wwdc  = OpenSSL::X509::Certificate.new File.read(@wwdc_cert)
      pk7   = OpenSSL::PKCS7.sign @key_hash[:cert], @key_hash[:key], data.to_s, [wwdc], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
      data  = OpenSSL::PKCS7.write_smime pk7

      str_debut = "filename=\"smime.p7s\"\n\n"
      data = data[data.index(str_debut)+str_debut.length..data.length-1]
      str_end = "\n\n------"
      data = data[0..data.index(str_end)-1]

      return Base64.decode64(data)
    end

    def compute_cert
      key_hash = {}
      if @key
        key_hash[:key]  = OpenSSL::PKey::RSA.new File.read(@key), @password
        key_hash[:cert] = OpenSSL::X509::Certificate.new File.read(@certificate)
      else
        p12 = OpenSSL::PKCS12.new File.read(@certificate), @password
        key_hash[:key], key_hash[:cert] = p12.key, p12.certificate
      end
      key_hash
    end
  end
end