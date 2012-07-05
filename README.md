# Passbook

Passbook gem let's you create pkpass for passbook iOS 6

## Installation

TODO : push the gem to rubygems.org

## Configuration

Configure it with config/initializers/passbook.rb

    Passbook.configure do |passbook|
      passbook.p12_cert = Rails.root.join("cert.p12")
      passbook.p12_password = 'cert password'
    end

## Usage

Please refer to apple iOS dev center for how to build cert and json

    pass = Passbook::PKPass.new 'your json data'
    pass.addFile 'Path to your file'
    pkpass_path = pass.create
    send_file pkpass_path, type: 'application/vnd.apple.pkpass', disposition: 'attachment', filename: "pass.pkpass"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request