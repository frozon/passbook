require 'spec_helper'

describe Passbook  do

  let (:content) {{
    :formatVersion => 1,
    :passTypeIdentifier => "pass.passbook.test",
    :serialNumber => "001",
    :teamIdentifier => ENV['APPLE_TEAM_ID'],
    :relevantDate => "2012-10-02",
    :locations => [  #TODO
      {
    :longitude => 2.35403,
    :latitude => 48.893855
  }
  ],
    :organizationName => "WorldCo",
    :description => "description",
    :foregroundColor => "rgb(227,210,18)",
    :backgroundColor => "rgb(60, 65, 76)",
    :logoText => "Event",
    :eventTicket => {
    :primaryFields => [
      {
    :key => "date",
    :label => "DATE",
    :value => "date"
  }
  ],
    :backFields => [
      {
    :key => "description",
    :label => "DESCRIPTION",
    :value => "description"
  },
    {
    :key => "aboutUs",
    :label => "MORE",
    :value => "about us"
  }
  ]
  }
  }}

  let (:pass) {Passbook::PKPass.new content.to_json}

  context 'signatures' do
    before do
      Passbook.should_receive(:p12_password).and_return 'password'
    end

    context 'p12_cert_and_key' do
      context 'pem p12 certs' do
        before do
          Passbook.should_receive(:p12_key).twice.and_return 'my_p12_key'
          Passbook.should_receive(:p12_certificate).and_return 'my_p12_certificate'
          File.should_receive(:read).with('my_p12_key').and_return 'my_p12_key_file'
          File.should_receive(:read).with('my_p12_certificate').and_return 'my_p12_certificate_file'
          OpenSSL::PKey::RSA.should_receive(:new).with('my_p12_key_file', 'password').and_return 'my_rsa_key'
          OpenSSL::X509::Certificate.should_receive(:new).with('my_p12_certificate_file').and_return 'my_ssl_p12_cert' 
        end

        subject {pass.get_p12_cert_and_key}
        its([:key]) {should eq 'my_rsa_key'}
        its([:cert]) {should eq 'my_ssl_p12_cert'}
      end

      context 'p12 files' do
        let (:p12) { double('OpenSSL::PKCS12') }
        let (:final_hash) {{:key => 'my_final_p12_key', :cert => 'my_final_p12_cert'}}
        before do
          p12.should_receive(:key).and_return final_hash[:key]
          p12.should_receive(:certificate).and_return final_hash[:cert]
          Passbook.should_receive(:p12_key).and_return nil
          Passbook.should_receive(:p12_cert).and_return 'my_p12_cert'
          File.should_receive(:read).with('my_p12_cert').and_return 'my_p12_cert_file'
          OpenSSL::PKCS12.should_receive(:new).with('my_p12_cert_file', 'password').and_return p12
        end

        subject {pass.get_p12_cert_and_key}
        its([:key]) {should eq final_hash[:key]}
        its([:cert]) {should eq final_hash[:cert]}
      end
    end
  end

  context 'outputs' do
    let (:base_path) {'spec/data'}
    let (:entries) {["pass.json", "manifest.json", "signature", "icon.png", "icon@2x.png", "logo.png", "logo@2x.png"]}

    before :each do
      pass.addFiles ["#{base_path}/icon.png","#{base_path}/icon@2x.png","#{base_path}/logo.png","#{base_path}/logo@2x.png"]
      pass.should_receive(:createSignature).and_return('Signed by the Honey Badger')
      @file_entries = []
      Zip::ZipInputStream::open(zip_path) {|io|
        while (entry = io.get_next_entry)
          @file_entries << entry.name
        end
      }
    end

    context 'zip file' do
      let(:zip_path) {pass.file.path}

      subject {entries}
      it {should eq @file_entries}
    end

    context 'StringIO' do
      let (:temp_file) {Tempfile.new("pass.pkpass")}
      let (:zip_path) {
        zip_out = pass.stream
        zip_out.class.should eq(Class::StringIO)
        #creating file, re-reading zip to see if correctly formed
        temp_file.write zip_out.string
        temp_file.close
        temp_file.path
      }

      subject {entries}
      it {should eq @file_entries}

      after do
        temp_file.delete
      end 
    end
  end
end
