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