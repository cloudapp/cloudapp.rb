require 'helper'
require 'support/fakefs_rspec'
require 'support/vcr_rspec'

require 'cloudapp/service'

describe CloudApp::Service do
  let(:token) { '8762f6679f8d001016b2' }

  describe '.using_token' do
    let(:service) { stub }

    it 'returns a new service using the token' do
      CloudApp::Service.should_receive(:new).and_return(service)
      service.should_receive(:token=).with(token)

      CloudApp::Service.using_token token
    end
  end

  describe '#token_for_account' do
    subject {
      VCR.use_cassette('Service/token_for_account') {
        CloudApp::Service.new.token_for_account 'arthur@dent.com', 'towel'
      }
    }

    it 'returns the token from the given account' do
      subject.should eql(token)
    end
  end

  describe '#drop' do
    let(:service) { CloudApp::Service.new }

    describe 'retrieving a drop' do
      let(:url) { 'http://cl.ly/C23W' }
      subject {
        VCR.use_cassette('Service/drop',
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
        VCR.use_cassette('Service/drop',
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
    let(:service)     { CloudApp::Service.new }
    let(:url)         { 'http://cl.ly/C23W' }
    let(:options)     { {} }
    let(:content)     { 'content' }
    let(:content_url) { 'http://cl.ly/C23W/drop_presenter.rb' }
    let(:drop)        { stub :drop, content:      content,
                                    content_url:  content_url,
                                    has_content?: true }

    before do
      CloudApp::DropContent.stub download: content
      service.stub drop: drop
    end

    it 'fetches the drop' do
      CloudApp::DropContent.should_receive(:download).with(drop)
      service.download_drop url, options
    end

    it 'returns the content' do
      service.download_drop(url, options).should eq(content)
    end

    it 'saves the file to the current directory using the remote filename' do
      service.download_drop url, options
      downloaded = File.open('drop_presenter.rb') {|f| f.read }

      downloaded.should eq(content)
    end

    describe 'to a path' do
      let(:options) {{ to: '/tmp/file.txt' }}

      it 'saves the file to the given path' do
        service.download_drop url, options
        File.exist?(options[:to]).should be_true
      end
    end

    describe 'to an existing file' do
      let(:options) {{ to: '/tmp/file.txt' }}
      before do
        Dir.mkdir '/tmp'
        File.open(options[:to], 'w', 0600) {|file| file << 'existing' }
      end

      it 'overwrites the file' do
        service.download_drop url, options
        downloaded = File.open(options[:to]) {|f| f.read }

        downloaded.should eq(content)
      end
    end

    describe 'an unexpanded path' do
      let(:options) {{ to: '~/file.txt' }}
      before do
        FileUtils.mkdir_p File.expand_path('~')
      end

      it 'saves the file to the expanded directory' do
        service.download_drop url, options
        saved_path = File.expand_path(options[:to])

        File.exist?(saved_path).should be_true
      end
    end

    describe 'to an existing directory' do
      let(:options) {{ to: '/tmp' }}
      before do
        Dir.mkdir '/tmp'
      end

      it 'raises an exception' do
        -> { service.download_drop url, options }.
          should raise_exception(Errno::EISDIR)
      end
    end

    describe 'a bookmark' do
      let(:drop) { stub :drop, has_content?: false }

      it 'raises an exception' do
        -> { service.download_drop url, options }.
          should raise_exception(CloudApp::Service::NO_CONTENT)
      end

      it "doesn't save a file" do
        FakeFS::FileSystem.files.should be_empty
      end
    end

    describe 'a file with URL-encoded name' do
      let(:content_url) { 'http://cl.ly/C23W/screen%20shot.png' }

      it 'decodes the filename' do
        service.download_drop url, options

        File.exist?('screen shot.png').should be_true
      end
    end

    describe 'a nonexistent drop' do
      let(:drop) { nil }

      it 'raises an exception' do
        -> { service.download_drop url, options }.
          should raise_exception(CloudApp::Service::NO_CONTENT)
      end

      it "doesn't save a file" do
        FakeFS::FileSystem.files.should be_empty
      end
    end
  end

  describe '#drops' do
    let(:service) { CloudApp::Service.using_token token }
    subject { VCR.use_cassette('Service/list_drops') { service.drops }}

    it 'has 20 drops' do
      subject.should have(20).items
    end

    it 'creates Drops' do
      subject.each {|drop| drop.should be_a(CloudApp::Drop) }
    end

    it 'delegates links to response' do
      href = Addressable::URI.
               parse('https://my.cl.ly/items?api_version=1.2&per_page=20')
      subject.link('self').should eq(href)
    end

    context 'with href' do
      let(:href) { 'https://my.cl.ly/items?api_version=1.2&page=2&per_page=20' }
      subject {
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: href
        }
      }

      it 'returns the resource at the given href' do
        subject.link('self').should eq(Addressable::URI.parse(href))
      end
    end

    context 'with limit' do
      let(:limit) { 5 }
      subject {
        VCR.use_cassette('Service/list_drops_with_limit') {
          service.drops limit: limit
        }
      }

      it 'has the given number of drops' do
        subject.should have(limit).items
      end
    end

    context 'with limit and href' do
      let(:href) { 'https://my.cl.ly/items?api_version=1.2&page=2&per_page=20' }
      subject {
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: href, limit: 1
        }
      }

      it 'ignores limit' do
        subject.should have(20).items
      end
    end
  end

  describe '#trash' do
    let(:service) { CloudApp::Service.using_token token }
    subject { VCR.use_cassette('Service/list_trash') { service.trash }}

    it 'has 2 drops' do
      subject.should have(2).items
    end

    it 'creates Drops' do
      subject.each {|drop| drop.should be_a(CloudApp::Drop) }
    end

    it 'delegates links to response' do
      href = Addressable::URI.
               parse('https://my.cl.ly/items?api_version=1.2&per_page=20&deleted=true')
      subject.link('self').should eq(href)
    end

    context 'with limit' do
      let(:limit) { 1 }
      subject {
        VCR.use_cassette('Service/list_trash_with_limit') {
          service.trash limit: limit
        }
      }

      it 'has the given number of drops' do
        subject.should have(limit).items
      end
    end
  end

  describe '#create' do
    let(:service) { CloudApp::Service.using_token token }
    let(:url)     { 'http://getcloudapp.com' }
    let(:name)    { 'CloudApp' }

    describe 'creating a bookmark' do
      subject {
        VCR.use_cassette('Service/create_bookmark') {
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
        VCR.use_cassette('Service/create_bookmark_with_name') {
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
        VCR.use_cassette('Service/create_public_bookmark') {
          service.create url: url, name: name, private: false
        }
      }

      it 'is public' do
        subject.should be_public
      end
    end

    describe 'creating a private bookmark' do
      subject {
        VCR.use_cassette('Service/create_private_bookmark') {
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
        VCR.use_cassette('Service/upload_file') {
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
        VCR.use_cassette('Service/upload_public_file') {
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
    let(:service) { CloudApp::Service.using_token token }

    describe '#token_for_account' do
      subject {
        VCR.use_cassette('Service/token_for_account_with_bad_credentials') {
          CloudApp::Service.new.
            token_for_account('ford@prefect.com', 'earthling')
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::Service::UNAUTHORIZED)
      end
    end

    describe '#drops' do
      subject {
        VCR.use_cassette('Service/list_drops_with_bad_credentials') {
          service.drops
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::Service::UNAUTHORIZED)
      end
    end

    describe '#trash' do
      subject {
        VCR.use_cassette('Service/list_trash_with_bad_credentials') {
          service.trash
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::Service::UNAUTHORIZED)
      end
    end

    describe '#create' do
      subject {
        VCR.use_cassette('Service/create_bookmark_with_bad_credentials') {
          service.create url: 'http://getcloudapp.com'
        }
      }

      it 'raises an unauthorized error' do
        lambda { subject }.
          should raise_error(CloudApp::Service::UNAUTHORIZED)
      end
    end
  end
end
