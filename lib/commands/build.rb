command :build do |c|
  c.syntax = 'pk build [PASSNAME]'
  c.summary = 'Creates a .pkpass archive'
  c.description = ''

  c.example 'description', 'pk archive mypass -o mypass.pkpass'
  c.option '-w', '--wwdc_certificate /path/to/wwdc_cert.pem', 'Pass certificate'
  c.option '-k', '--p12_key /path/to/cert.p12'
  c.option '-c', '--p12_certificate /path/to/cert.p12'
  c.option '-p', '--password password', 'certificate password'
  c.option '-o', '--output /path/to/out.pkpass', '.pkpass output filepath'

  c.action do |args, options|
    determine_directory! unless @directory = args.first
    validate_directory!

    @filepath = options.output || "#{@directory}.pkpass"
    validate_output_filepath!

    @certificate = options.wwdc_certificate
    validate_certificate!

    @password = (options.password ? options.password : (ask("Enter certificate password:"){|q| q.echo = false}))

    Passbook.configure do |passbook|
      passbook.wwdc_cert = @certificate
      passbook.p12_key = options.p12_key
      passbook.p12_certificate = options.p12_certificate
      passbook.p12_password = @password
    end

    assets = CommandUtils.get_assets @directory
    pass_json = File.read(assets.delete(assets.detect{|file| File.basename(file) == 'pass.json'}))
    pass = Passbook::PKPass.new(pass_json)
    pass.addFiles assets

    begin
      pass_stream = pass.stream
      pass_string = pass_stream.string

      File.open(@filepath, 'w') do |f|
        f.write  pass_string
      end
    rescue OpenSSL::PKCS12::PKCS12Error => error
      say_error "Error: #{error.message}"
      say_warning "You may be getting this error because the certificate password is either incorrect or missing"
      abort
    rescue => error
      say_error "Error: #{error.message}" and abort
    end
  end
end

alias_command :archive, :build
alias_command :b, :build

private

def validate_output_filepath!
  say_error "Filepath required" and abort if @filepath.nil? or @filepath.empty?
  say_error "#{@filepath} already exists" and abort if File.exist?(@filepath)
end
