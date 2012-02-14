require 'helper'
require 'support/vcr_rspec'

require 'cloudapp/drop_service'

describe CloudApp::DropService do

  let(:token) { '8762f6679f8d001016b2' }

  describe '.using_token' do
    subject { CloudApp::DropService.using_token(token) }

    it 'returns a service authenticated with given token' do
      VCR.use_cassette('DropService/list_drops') {
        subject.drops
      }
    end
  end

  describe '.retrieve_token' do
    subject {
      VCR.use_cassette('DropService/retrieve_token') {
        CloudApp::DropService.retrieve_token 'arthur@dent.com', 'towel'
      }
    }

    it 'returns the token from the given account' do
      subject.should eql(token)
    end
  end

  describe '#drops' do
    let(:service) { CloudApp::DropService.using_token token }

    describe 'listing drops' do
      subject { VCR.use_cassette('DropService/list_drops') { service.drops }}

      it 'has 20 drops' do
        subject.should have(20).items
      end

      it 'creates Drops' do
        subject.each {|drop| drop.should be_a(CloudApp::Drop) }
      end
    end

    describe 'listing trash' do
      subject { VCR.use_cassette('DropService/list_trash') { service.trash }}

      it 'has 2 drops' do
        subject.should have(2).items
      end

      it 'creates Drops' do
        subject.each {|drop| drop.should be_a(CloudApp::Drop) }
      end
    end

    describe 'limiting drops list' do
      let(:limit) { 5 }

      subject {
        VCR.use_cassette('DropService/list_drops_with_limit') {
          service.drops limit
        }
      }

      it 'has the given number of drops' do
        subject.should have(limit).items
      end
    end
  end

  describe '#create' do
    let(:service) { CloudApp::DropService.using_token token }
    let(:url)     { 'http://getcloudapp.com' }
    let(:name)    { 'CloudApp' }

    describe 'creating a bookmark' do
      subject {
        VCR.use_cassette('DropService/create_bookmark') {
          service.create url: url
        }
      }

      it 'is a Drop' do
        subject.should be_a(CloudApp::Drop)
      end

      it 'has the given url' do
        subject.redirect_url.should eq(url)
      end

      it 'has no name' do
        subject.name.should_not be
      end
    end

    describe 'creating a bookmark with a name' do
      subject {
        VCR.use_cassette('DropService/create_bookmark_with_name') {
          service.create url: url, name: name
        }
      }

      it 'has the given url' do
        subject.redirect_url.should eq(url)
      end

      it 'has the given name' do
        subject.name.should eq(name)
      end
    end

    describe 'creating a public bookmark' do
      subject {
        VCR.use_cassette('DropService/create_public_bookmark') {
          service.create url: url, name: name, private: false
        }
      }

      it 'is public' do
        subject.should be_public
      end
    end

    describe 'creating a private bookmark' do
      subject {
        VCR.use_cassette('DropService/create_private_bookmark') {
          service.create url: url, name: name, private: true
        }
      }

      it 'is private' do
        subject.should be_private
      end
    end

    describe 'uploading a file' do
      let(:path) do
        Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
      end

      subject {
        VCR.use_cassette('DropService/upload_file') {
          service.create path: path
        }
      }

      it 'is a Drop' do
        subject.should be_a(CloudApp::Drop)
      end

      it 'has a remote url' do
        subject.remote_url.
          should eq('http://f.cl.ly/items/1n331R181E100P3h2x3f/favicon.ico')
      end

      it 'has the name of the file' do
        subject.name.should eq('favicon.ico')
      end
    end

    describe 'uploading a public file' do
      let(:path) do
        Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
      end

      subject {
        VCR.use_cassette('DropService/upload_public_file') {
          service.create path: path, private: false
        }
      }

      it 'is public' do
        subject.should be_public
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

  describe 'with bad authentication' do
    let(:token)   { 'bad-token' }
    let(:service) { CloudApp::DropService.using_token token }

    describe '.retrieve_token' do
      subject {
        VCR.use_cassette('DropService/retrieve_token_with_bad_credentials') {
          CloudApp::DropService.retrieve_token 'ford@prefect.com', 'earthling'
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::DropService::UNAUTHORIZED)
      end
    end

    describe '#drops' do
      subject {
        VCR.use_cassette('DropService/list_drops_with_bad_credentials') {
          service.drops
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::DropService::UNAUTHORIZED)
      end
    end

    describe '#trash' do
      subject {
        VCR.use_cassette('DropService/list_trash_with_bad_credentials') {
          service.trash
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::DropService::UNAUTHORIZED)
      end
    end

    describe '#create' do
      subject {
        VCR.use_cassette('DropService/create_bookmark_with_bad_credentials') {
          service.create url: 'http://getcloudapp.com'
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::DropService::UNAUTHORIZED)
      end
    end
  end
end
