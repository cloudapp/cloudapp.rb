require 'helper'
require 'support/vcr_rspec'

# Using master branch of Leadlight
require 'bundler'
Bundler.setup

require 'cloudapp/drop_service'

describe CloudApp::DropService, :vcr do

  let(:logger) do
    logfile = Pathname('../../../log/test.log').expand_path(__FILE__)
    FileUtils.mkdir_p logfile.dirname
    Logger.new logfile
  end
  let(:service_options) {{ logger: logger }}
  let(:identity) { stub email: 'arthur@dent.com', password: 'towel' }

  describe '.as_identity' do
    it 'returns a service with given identity' do
      service = CloudApp::DropService.as_identity identity, service_options

      auth = service.connection.options[:authentication]
      auth.should be
      auth[:username].should eq(identity.email)
      auth[:password].should eq(identity.password)
    end
  end

  describe '#drops' do
    let(:service) { CloudApp::DropService.as_identity identity, service_options }

    describe 'listing drops' do
      subject { service.drops }

      it 'has 20 drops' do
        subject.should have(20).items
      end

      it 'creates Drops' do
        subject.each {|drop| drop.should be_a(Drop) }
      end
    end

    describe 'listing trash' do
      subject { service.trash }

      it 'has 2 drops' do
        subject.should have(2).items
      end

      it 'creates Drops' do
        subject.each {|drop| drop.should be_a(Drop) }
      end
    end

    describe 'limiting drops list' do
      let(:limit) { 5 }
      subject { service.drops limit }

      it 'has the given number of drops' do
        subject.should have(limit).items
      end
    end
  end

  describe '#create' do
    let(:service) { CloudApp::DropService.as_identity identity, service_options }
    let(:url)     { 'http://getcloudapp.com' }
    let(:name)    { 'CloudApp' }

    describe 'creating a bookmark' do
      subject { service.create url: url }

      it 'is a Drop' do
        subject.should be_a(Drop)
      end

      it 'has the given url' do
        subject.redirect_url.should eq(url)
      end

      it 'has no name' do
        subject.name.should_not be
      end
    end

    describe 'creating a bookmark with a name' do
      subject { service.create url: url, name: name }

      it 'has the given url' do
        subject.redirect_url.should eq(url)
      end

      it 'has the given name' do
        subject.name.should eq(name)
      end
    end

    describe 'uploading a file' do
      let(:path) do
        Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
      end
      subject { service.create path: path }

      it 'is a Drop' do
        subject.should be_a(Drop)
      end

      it 'has a remote url' do
        subject.remote_url.
          should eq('http://f.cl.ly/items/0L3T3d1q3A3b182V3c3T/favicon.ico')
      end

      it 'has the name of the file' do
        subject.name.should eq('favicon.ico')
      end
    end
  end

  describe '#destroy' do
    it 'trashes a drop'
    it 'destroys a trashed drop'
  end

  describe '#restore' do
    it 'restores a drop from the trash'
  end
end
