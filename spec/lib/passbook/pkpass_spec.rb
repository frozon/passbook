require 'passbook/pkpass'
require 'json'
require 'passbook'

describe Passbook  do

  before :all do
    Passbook.configure do |pass|
      pass.wwdc_cert = ENV['WWDC_PATH']
      pass.p12_cert = ENV['P12_PATH']
      pass.p12_password = ENV['PASSBOOK_P12_PASSWORD']
    end
    @content = {
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
              }
    @pass = Passbook::PKPass.new @content.to_json
  end
  
  it "should create a zip file by default" do
    base_path = "spec/data"
    @pass.addFiles ["#{base_path}/icon.png","#{base_path}/icon@2x.png","#{base_path}/logo.png","#{base_path}/logo@2x.png"]
    entries = ["pass.json", "manifest.json", "signature", "icon.png", "icon@2x.png", "logo.png", "logo@2x.png"]
    zip_path = @pass.create
    #re-reading zip to see if correctly formed
    Zip::ZipInputStream::open(zip_path) {|io|
      while (entry = io.get_next_entry)
        entries.should include(entry.name)
      end
    }
  end

  it "should create a stringIO output if selected" do
    base_path = "spec/data"
    @pass.addFiles ["#{base_path}/icon.png","#{base_path}/icon@2x.png","#{base_path}/logo.png","#{base_path}/logo@2x.png"]
    entries = ["pass.json", "manifest.json", "signature", "icon.png", "icon@2x.png", "logo.png", "logo@2x.png"]
    zip_out = @pass.create({ in_memory: true })
    zip_out.class.should eq(Class::StringIO)
    #creating file, re-reading zip to see if correctly formed
    t = Tempfile.new("pass.pkpass")
    t.write zip_out.string
    t.close
    Zip::ZipInputStream::open(t.path) {|io|
      while (entry = io.get_next_entry)
        entries.should include(entry.name)
      end
    }
    t.delete
  end 

end