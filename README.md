[![Build Status](https://travis-ci.org/lgleasain/passbook.png)](https://travis-ci.org/lgleasain/passbook)

# Passbook

Passbook gem let's you create pkpass for passbook iOS 6

## Installation

TODO : push the gem to rubygems.org

## Configuration

Create initializer
```
    rails g passbook:config
    or with params
    rails g passbook:config [Absolute path to the wwdc cert file] [Absolute path to your cert.p12 file] [Password for your certificate]
```

Configure your config/initializers/passbook.rb 
```
    Passbook.configure do |passbook|
      passbook.wwdc_cert = Rails.root.joint('wwdc_cert.pem')
      passbook.p12_cert = Rails.root.join('cert.p12')
      passbook.p12_password = 'cert password'
    end
```
If you are using Sinatra you can place this in the file you are executing or in a file that you do a require on.

## Usage

Please refer to apple iOS dev center for how to build cert and json
```
    pass = Passbook::PKPass.new 'your json data'

    # Add file from disk
    pass.addFile 'file_path'

    # Add file from memory
    file[:name] = 'file name'
    file[:content] = 'whatever you want'
    pass.addFile file

    # Add multiple files
    pass.addFiles [file_path_1, file_path_2, file_path_3]

    # Add multiple files from memory
    pass.addFiles [{name: 'file1', content: 'content1'}, {name: 'file2', content: 'content2'}, {name: 'file3', content: 'content3'}]

    # Output a Tempfile

    pkpass = pass.file
    send_file pkpass.path, type: 'application/vnd.apple.pkpass', disposition: 'attachment', filename: "pass.pkpass"

    # Or a stream

    pkpass = pass.stream
    send_data pkpass.string, type: 'application/vnd.apple.pkpass', disposition: 'attachment', filename: "pass.pkpass"

```
if you are using Sinatra you will need to include the 'active_support' gem and will need to require 'active_support/json/encoding'

We will try to make this cleaner in the next release.

## Tests

  To launch tests : 
```
  bundle exec rspec spec/lib/passbook/pkpass_spec.rb
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Changelog

### 0.0.4
Allow passbook gem to return a ZipOutputStream (needed when garbage collector delete tempfile before beeing able to use it) [Thx to applidget]

License
-------

passbook-ios is released under the MIT license:

* http://www.opensource.org/licenses/MIT
