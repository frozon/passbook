require 'openssl'
require 'base64'

module Passbook
  class Signer
    attr_accessor :certificate, :password, :key, :wwdc_cert, :key_hash, :p12_cert

    def initialize(params = {})
      @certificate = params[:certificate] || Passbook.p12_certificate
      @password    = params[:password] || Passbook.p12_password
      @key         = params[:key] || (params.empty? ? Passbook.p12_key : nil)
      @wwdc_cert   = params[:wwdc_cert] || Passbook.wwdc_cert
      compute_cert
    end

    def sign(data)
      wwdc  = OpenSSL::X509::Certificate.new File.read(wwdc_cert)
      pk7   = OpenSSL::PKCS7.sign key_hash[:cert], key_hash[:key], data.to_s, [wwdc], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
      data  = OpenSSL::PKCS7.write_smime pk7

      str_debut = "filename=\"smime.p7s\"\n\n"
      data      = data[data.index(str_debut)+str_debut.length..data.length-1]
      str_end   = "\n\n------"
      data      = data[0..data.index(str_end)-1]

      Base64.decode64(data)
    end

    def compute_cert
      @key_hash = {}
      if key
        @key_hash[:key]  = OpenSSL::PKey::RSA.new File.read(key), password
        @key_hash[:cert] = OpenSSL::X509::Certificate.new File.read(certificate)
      else
        p12 = OpenSSL::PKCS12.new certificate_data, password
        @key_hash[:key], @key_hash[:cert] = p12.key, p12.certificate
      end
    end

    def certificate_data
      certificate.is_a?(Pathname) ? File.read(certificate) : certificate
    end
  end
end
