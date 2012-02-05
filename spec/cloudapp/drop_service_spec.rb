require 'helper'
require 'support/vcr_rspec'

# Using master branch of Leadlight
require 'bundler'
Bundler.setup

require 'cloudapp/drop_service'

describe DropService, :vcr do

  let(:logger) do
    logfile = Pathname('../../../log/test.log').expand_path(__FILE__)
    FileUtils.mkdir_p logfile.dirname
    Logger.new logfile
  end
  let(:service_options) {{ logger: logger }}
  let(:identity) { stub email: 'arthur@dent.com', password: 'towel' }

  describe '.as_identity' do
    it 'returns a service with given identity' do
      service = DropService.as_identity identity, service_options

      auth = service.connection.options[:authentication]
      auth.should be
      auth[:username].should eq(identity.email)
      auth[:password].should eq(identity.password)
    end
  end

  describe '#drops' do
    let(:service) { DropService.as_identity identity, service_options }

    it 'returns a list of drops' do
      service.drops.should have(20).items
    end

    it 'returns a list of trashed drops' do
      service.trash.should have(2).items
    end
  end

  describe '#create' do
    let(:service) { DropService.as_identity identity, service_options }
    let(:url)     { 'http://getcloudapp.com' }
    let(:name)    { 'CloudApp' }

    it 'creates a bookmark' do
      expect_cassettes_used(2) do
        drop = service.create url: url

        drop['redirect_url'].should eq(url)
        drop['name'].should_not be
      end
    end

    it 'creates a bookmark with a name' do
      expect_cassettes_used(2) do
        drop = service.create url: url, name: name

        drop['redirect_url'].should eq(url)
        drop['name'].should eq(name)
      end
    end

    it 'creates a file' do
      path = Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
      drop = service.create path: path

      drop['remote_url'].
        should eq('http://f.cl.ly/items/0T442i0A1z1a3O0h3K0U/favicon.ico')
      drop['name'].should eq('favicon.ico')
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
