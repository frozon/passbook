Passbook.configure do |passbook|

  # Path to your wwdc cert file
  passbook.wwdc_cert = '<%= wwdc_cert_path %>'

  # Path to your cert.p12 file
  passbook.p12_cert = '<%= p12_cert_path %>'
  
  # Password for your certificate
  passbook.p12_password = '<%= p12_password %>'
end