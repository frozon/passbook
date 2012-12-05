require 'spec_helper'

describe Rack::PassbookRack  do

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
      context 'passbook api path' do
        subject {passbook_rack.find_method('/v1/devices/fe772e610be3efafb65ed77772ca311a/registrations/pass.com.polyglotprogramminginc.testpass/27-1')}
        its(['method']) {should eq 'device_register_delete'}
        its(['params']) {should eq('deviceLibraryIdentifier' => 'fe772e610be3efafb65ed77772ca311a',
                                   'passTypeIdentifier' => 'pass.com.polyglotprogramminginc.testpass',
                                   'serialNumber' => '27-1') }
      end

      it_behaves_like 'a method that can handle non passbook urls' 

    end

    context 'passes for device' do
      context 'passbook api path' do
        subject {passbook_rack.find_method('/v1/devices/fe772e610be3efafb65ed77772ca311a/registrations/pass.com.polyglotprogramminginc.testpass')}
        its(['method']) {should eq 'passes_for_device'}
        its(['params']) {should eq('deviceLibraryIdentifier' => 'fe772e610be3efafb65ed77772ca311a',
                                   'passTypeIdentifier' => 'pass.com.polyglotprogramminginc.testpass') }
      end

      it_behaves_like 'a method that can handle non passbook urls' 

    end
  end
end
