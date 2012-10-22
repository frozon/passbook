require 'passbook/pkpass'
require 'json'
require 'passbook'

describe Passbook  do

  before :all do
    Passbook.configure do |pass|
      pass.wwdc_cert = '../mobicheckin-server/lib/passbook/wwdr_certificate.cer'
      pass.p12_cert = '../mobicheckin-server/lib/passbook/mobicheckin_passbook.p12'
      pass.p12_password = ENV['PASSBOOK_P12_PASSWORD']
    end
    @content = {
                formatVersion: 1,
                passTypeIdentifier: "pass.mobicheckin.badge",
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
  
  it "should create correct zip" do
    base_path = "../mobicheckin-server/app/assets/images/passbook"
    @pass.addFiles ["#{base_path}/icon.png","#{base_path}/icon@2x.png","#{base_path}/logo.png","#{base_path}/logo@2x.png"]
    entries = ["pass.json", "manifest.json", "signature", "icon.png", "icon@2x.png", "logo.png", "logo@2x.png"]
    zip_path = @pass.create({})
    #re-reading zip to see if correctly formed
    Zip::ZipInputStream::open(zip_path) {|io|
      while (entry = io.get_next_entry)
        entries.should include(entry.name)
      end
    }
  end

end