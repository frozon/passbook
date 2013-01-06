require 'spec_helper'
require 'grocer'

describe Passbook::PushNotification  do

  context 'send notification' do
    let(:grocer_pusher) {double 'Grocer'}
    let(:notification) {double 'Grocer::Notification'} 
    let(:notification_settings) {{:certificate => './notification_cert.pem', :gateway => 'honeybadger.apple.com'}}

    before :each do
      Passbook.should_receive(:notification_cert).and_return './notification_cert.pem'
      Grocer::PassbookNotification.should_receive(:new).with(:device_token => 'my token').and_return notification 
      grocer_pusher.should_receive(:push).with(notification).and_return 55
      Grocer.should_receive(:pusher).with(notification_settings).and_return grocer_pusher
      Passbook.should_receive(:notification_gateway).and_return 'honeybadger.apple.com'
    end

    subject {Passbook::PushNotification.send_notification('my token')}
    it {should eq 55}
  end
end
