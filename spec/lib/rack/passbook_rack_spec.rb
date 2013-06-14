require 'spec_helper'

describe Rack::PassbookRack  do

  let(:register_delete_path) {'/v1/devices/fe772e610be3efafb65ed77772ca311a/registrations/pass.com.polyglotprogramminginc.testpass/27-1'}
  let(:register_delete_params) {{'deviceLibraryIdentifier' => 'fe772e610be3efafb65ed77772ca311a',
    'passTypeIdentifier' => 'pass.com.polyglotprogramminginc.testpass',
    'serialNumber' => '27-1'}}
  let(:passes_for_device_path) {'/v1/devices/fe772e610be3efafb65ed77772ca311a/registrations/pass.com.polyglotprogramminginc.testpass'}
  let(:passes_for_device_params) {{'deviceLibraryIdentifier' => 'fe772e610be3efafb65ed77772ca311a',
    'passTypeIdentifier' => 'pass.com.polyglotprogramminginc.testpass'}}
  let(:latest_pass_path) {'/v1/passes/pass.com.polyglotprogramminginc.testpass/27-1'}
  let(:latest_pass_params) {{'passTypeIdentifier' => 'pass.com.polyglotprogramminginc.testpass',
                                'serialNumber' => '27-1'}}
  let(:log_path) {'/v1/log'}
  let(:push_token) {"8c56f2e787d9c089963960ace834bc2875e3f0cf7745da5b98d58bc6be05b4dc"}
  let(:auth_token) {"3c0adc9ccbcf3e733edeb897043a4835"}

  context 'find method' do
    let(:passbook_rack) {Rack::PassbookRack.new nil}

    shared_examples_for 'a method that can handle non passbook urls' do
      context 'incomplete passbook api path' do
        subject {passbook_rack.find_method('/v1/devices/fe772e610be3efafb65ed77772ca311a/registrations')}
        it {should eq nil}
      end

      context 'no version api path' do
        subject {passbook_rack.find_method('/devices/fe772e610be3efafb65ed77772ca311a/registrations')}
        it {should eq nil}
      end

      context 'no devices api path' do
        subject {passbook_rack.find_method('/v1/fe772e610be3efafb65ed77772ca311a/registrations')}
        it {should eq nil}
      end

      context 'no registrations api path' do
        subject {passbook_rack.find_method('/v1/devices/fe772e610be3efafb65ed77772ca311a')}
        it {should eq nil}
      end
    end

    context 'device register delete' do
      context 'a valid path' do
        subject {passbook_rack.find_method(register_delete_path)}
        its([:method]) {should eq 'device_register_delete'}
        its([:params]) {should eq(register_delete_params) }
      end

      it_behaves_like 'a method that can handle non passbook urls' 

    end

    context 'passes for device' do
      subject {passbook_rack.find_method(passes_for_device_path)}
      its([:method]) {should eq 'passes_for_device'}
      its([:params]) {should eq passes_for_device_params }
    end

    context 'latest pass' do
      subject {passbook_rack.find_method(latest_pass_path)}
      its([:method]) {should eq 'latest_pass'}
      its([:params]) {should eq(latest_pass_params) }
    end

    context 'latest pass' do
      subject {passbook_rack.find_method(log_path)}
      its([:method]) {should eq 'log'}
    end
  end

  context 'rack middleware' do

    context 'register pass without authToken' do
      before do
        Passbook::PassbookNotification.should_receive(:register_pass).
          with(register_delete_params.merge!('pushToken' => push_token)).and_return({:status => 201})
        post register_delete_path, {"pushToken" => push_token}.to_json
      end

      subject {last_response}
      its(:status) {should eq 201}
    end

    context 'register pass with authToken' do
      before do
        Passbook::PassbookNotification.should_receive(:register_pass).
          with(register_delete_params.merge!('pushToken' => push_token,'authToken' => auth_token)).and_return({:status => 201})
        post register_delete_path, {"pushToken" => push_token}.to_json, rack_env = {'HTTP_AUTHORIZATION' => auth_token}
      end

      subject {last_response}
      its(:status) {should eq 201}
    end

    context 'passes for device' do
      context 'with passes' do
        let(:passes_for_device_response) {{'last_updated' => 1, 'serial_numbers' => [343, 234]}}
        before do
          Passbook::PassbookNotification.should_receive(:passes_for_device).
            with(passes_for_device_params).and_return(passes_for_device_response)
          get passes_for_device_path
        end

        context 'status' do
          subject {last_response.status}
          it {should eq 200}
        end

        context 'body' do
          subject{JSON.parse(last_response.body)}
          it {should eq passes_for_device_response}
        end
      end

      context 'without passes' do
        before do
          Passbook::PassbookNotification.should_receive(:passes_for_device).
            with(passes_for_device_params).and_return(nil)
          get passes_for_device_path
        end

        context 'status' do
          subject {last_response.status}
          it {should eq 204}
        end
      end
    end

    context 'get latest pass' do
      context 'valid pass' do
        let(:raw_pass) {'some url encoded text'}

        before do
          Passbook::PassbookNotification.should_receive(:latest_pass).with(latest_pass_params).
            and_return(raw_pass)
          get latest_pass_path
        end

        subject {last_response}
        its(:status) {should eq 200}
        its(:header) {should eq({'Content-Type' => 'application/vnd.apple.pkpass', 
          'Content-Disposition' => 'attachment', 'filename' => '27-1.pkpass', 'Content-Length' => '21'})}
        its(:body) {should eq raw_pass}
      end

      context 'no pass' do
        before do
          Passbook::PassbookNotification.should_receive(:latest_pass).with(latest_pass_params).
            and_return(nil)
          get latest_pass_path
        end

        subject {last_response}
        its(:status) {should eq 204}
      end
    end

    context 'unregister pass without authToken' do
      before do
        Passbook::PassbookNotification.should_receive(:unregister_pass).
          with(register_delete_params).and_return({:status => 200})
        delete register_delete_path
      end

      subject {last_response}
      its(:status) {should eq 200}
    end

    context 'unregister pass with authToken' do
      before do
        Passbook::PassbookNotification.should_receive(:unregister_pass).
          with(register_delete_params.merge!('authToken' => auth_token)).and_return({:status => 200})
        delete register_delete_path, {}, rack_env = {'HTTP_AUTHORIZATION' => auth_token}
      end

      subject {last_response}
      its(:status) {should eq 200}
    end

    context 'log' do
      let(:log_params) {{'logs' => ['some error']}}
      before do
        Passbook::PassbookNotification.should_receive(:passbook_log).
          with(log_params)
        post log_path, log_params.to_json
      end

      subject {last_response}
      its(:status) {should eq 200}
    end

    context 'non passbook requests' do
      before do
        get '/foo'
      end

      subject {last_response}
      its(:status) {should eq 200}
      its(:body) {should eq 'test app'}
    end    
  end

end

require 'rack/test'
include Rack::Test::Methods

def app
  test_app = lambda do |env|
    [200, {}, 'test app']
  end 

  Rack::PassbookRack.new test_app
end

class Passbook::PassbookNotification
end
