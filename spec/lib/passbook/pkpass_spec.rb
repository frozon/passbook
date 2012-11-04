require 'passbook/pkpass'
require 'json'
require 'passbook'

describe Passbook  do

  let (:content) {{
    formatVersion: 1,
    passTypeIdentifier: "pass.passbook.test",
    serialNumber: "001",
    teamIdentifier: ENV['APPLE_TEAM_ID'],
    relevantDate: "2012-10-02",
    locations: [  #TODO
      {
    longitude: 2.35403,
    latitude: 48.893855
  }
  ],
    organizationName: "WorldCo",
    description: "description",
    foregroundColor: "rgb(227,210,18)",
    backgroundColor: "rgb(60, 65, 76)",
    logoText: "Event",
    eventTicket: {
    primaryFields: [
      {
    key: "date",
    label: "DATE",
    value: "date"
  }
  ],
    backFields: [
      {
    key: "description",
    label: "DESCRIPTION",
    value: "description"
  },
    {
    key: "aboutUs",
    label: "MORE",
    value: "about us"
  }
  ]
  }
  }}

  let (:pass) {Passbook::PKPass.new content.to_json}

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
      let(:zip_path) {pass.file}

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
