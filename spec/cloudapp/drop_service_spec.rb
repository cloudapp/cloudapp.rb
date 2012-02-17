require 'helper'
require 'support/fakefs_rspec'
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

  describe '#drop' do
    let(:service) { CloudApp::DropService.new }

    describe 'retrieving a drop' do
      let(:url) { 'http://cl.ly/C23W' }
      subject {
        VCR.use_cassette('DropService/drop',
                         match_requests_on: [:method, :uri, :body, :headers]) {
          service.drop url
        }
      }

      it 'returns the drop' do
        subject.should be_a(CloudApp::Drop)
      end

      it 'parses the response' do
        subject.id.should == 12142483
      end
    end

    describe 'retrieving a nonexistent drop' do
      let(:url) { 'http://cl.ly/nonexistent' }
      subject {
        VCR.use_cassette('DropService/drop',
                         match_requests_on: [:method, :uri, :body, :headers]) {
          service.drop url
        }
      }

      it 'returns nil' do
        subject.should be_nil
      end
    end
  end

  describe '#download_drop', :fakefs do
    let(:service)     { CloudApp::DropService.new }
    let(:url)         { 'http://cl.ly/C23W' }
    let(:options)     {{ to: '.' }}
    let(:content)     { 'content' }
    let(:content_url) { 'http://cl.ly/C23W/drop_presenter.rb' }
    let(:drop)        { stub :drop, content: content, content_url: content_url }

    before { service.stub(drop: drop) }

    describe 'downloading a drop' do
      it 'fetches the drop' do
        service.should_receive(:drop).with(url).and_return(drop)
        service.download_drop url, options
      end

      it 'returns the content' do
        service.download_drop(url, options).should eq(content)
      end

      it 'saves the file' do
        service.download_drop url, options
        downloaded = File.open('drop_presenter.rb') {|f| f.read }

        downloaded.should eq(content)
      end

      it 'saves to another directory' do
        Dir.mkdir '/tmp'
        service.download_drop url, to: '/tmp'
        downloaded = File.open('/tmp/drop_presenter.rb') {|f| f.read }

        downloaded.should eq(content)
      end
    end

    describe 'downloading a nonexistent drop' do
      let(:drop) { nil }

      it 'returns nil' do
        service.download_drop(url, options).should be_nil
      end

      it "doesn't save a file" do
        FakeFS::FileSystem.files.should be_empty
      end
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
          should eq('http://f.cl.ly/items/0P3c3c1V3v1H3I3p3x0k/favicon.ico')
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
