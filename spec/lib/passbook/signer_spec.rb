require 'spec_helper'

describe 'Signer'  do
  context 'signatures' do

    context 'p12_cert_and_key' do
      context 'pem p12 certs' do
        context 'using config file certificates' do
          before do
            Passbook.should_receive(:p12_password).and_return 'password'
            Passbook.should_receive(:p12_key).and_return 'my_p12_key'
            Passbook.should_receive(:p12_certificate).and_return 'my_p12_certificate'
            Passbook.should_receive(:wwdc_cert).and_return 'i_love_robots'
            File.should_receive(:read).with('my_p12_key').and_return 'my_p12_key_file'
            File.should_receive(:read).with('my_p12_certificate').and_return 'my_p12_certificate_file'
            OpenSSL::PKey::RSA.should_receive(:new).with('my_p12_key_file', 'password').and_return 'my_rsa_key'
            OpenSSL::X509::Certificate.should_receive(:new).with('my_p12_certificate_file').and_return 'my_ssl_p12_cert'
          end

          subject {Passbook::Signer.new.key_hash}
          its([:key]) {should eq 'my_rsa_key'}
          its([:cert]) {should eq 'my_ssl_p12_cert'}
        end

        context 'using passed in certificates' do
          before do
            Passbook.should_receive(:p12_password).never
            Passbook.should_receive(:p12_key).never
            Passbook.should_receive(:p12_certificate).never
            Passbook.should_receive(:wwdc_cert).never
            File.should_receive(:read).with('my_p12_key').and_return 'my_p12_key_file'
            File.should_receive(:read).with('my_p12_certificate').and_return 'my_p12_certificate_file'
            OpenSSL::PKey::RSA.should_receive(:new).with('my_p12_key_file', 'password').and_return 'my_rsa_key'
            OpenSSL::X509::Certificate.should_receive(:new).with('my_p12_certificate_file').and_return 'my_ssl_p12_cert'
          end

          subject {Passbook::Signer.new(certificate: 'my_p12_certificate', password: 'password',
                                        key: 'my_p12_key', wwdc_cert: 'i_love_robots').key_hash}
          its([:key]) {should eq 'my_rsa_key'}
          its([:cert]) {should eq 'my_ssl_p12_cert'}
        end
      end

      context 'p12 files' do
        let (:p12) { double('OpenSSL::PKCS12') }
        let (:final_hash) {{:key => 'my_final_p12_key', :cert => 'my_final_p12_cert'}}
        let (:cert_path) { Pathname.new('./my_p12_cert')}
        context 'using config file certificates' do
          before do
            p12.should_receive(:key).and_return final_hash[:key]
            p12.should_receive(:certificate).and_return final_hash[:cert]
            Passbook.should_receive(:p12_password).and_return 'password'
            Passbook.should_receive(:wwdc_cert).and_return 'i_love_robots'
            Passbook.should_receive(:p12_certificate).and_return cert_path
            Passbook.should_receive(:p12_key).and_return nil
            File.should_receive(:read).with(cert_path).and_return 'my_p12_certificate_file'
            OpenSSL::PKCS12.should_receive(:new).with('my_p12_certificate_file', 'password').and_return p12
          end

          subject {Passbook::Signer.new.key_hash}
          its([:key]) {should eq final_hash[:key]}
          its([:cert]) {should eq final_hash[:cert]}
        end

        context 'using passed in certificates' do
          before do
            p12.should_receive(:key).and_return final_hash[:key]
            p12.should_receive(:certificate).and_return final_hash[:cert]
            Passbook.should_receive(:p12_password).never
            Passbook.should_receive(:p12_key).never
            Passbook.should_receive(:p12_certificate).never
            Passbook.should_receive(:wwdc_cert).never
            File.should_receive(:read).with(cert_path).and_return 'my_p12_certificate_file'
            OpenSSL::PKCS12.should_receive(:new).with('my_p12_certificate_file', 'password').and_return p12
          end

          subject {Passbook::Signer.new(certificate: cert_path, password: 'password',
                                        wwdc_cert: 'i_love_robots').key_hash}
          its([:key]) {should eq final_hash[:key]}
          its([:cert]) {should eq final_hash[:cert]}
        end

        context 'using passed in certificates as binary' do
          before do
            p12.should_receive(:key).and_return final_hash[:key]
            p12.should_receive(:certificate).and_return final_hash[:cert]
            Passbook.should_receive(:p12_password).never
            Passbook.should_receive(:p12_key).never
            Passbook.should_receive(:p12_certificate).never
            Passbook.should_receive(:wwdc_cert).never
            File.should_receive(:read).with(cert_path).and_return 'my_p12_certificate_file'
            OpenSSL::PKCS12.should_receive(:new).with('my_p12_certificate_file', 'password').and_return p12
          end

          subject {Passbook::Signer.new(certificate: File.read(cert_path), password: 'password',
                                        wwdc_cert: 'i_love_robots').key_hash}
          its([:key]) {should eq final_hash[:key]}
          its([:cert]) {should eq final_hash[:cert]}
        end
      end
    end
  end
end
