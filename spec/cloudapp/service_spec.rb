require 'helper'
require 'support/vcr'

require 'cloudapp/service'

describe CloudApp::Service do
  let(:service) { CloudApp::Service.using_token token }
  let(:token)   { 'abc123' }
  let(:favicon) {
    Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
  }

  after(:all) do
    VCR.use_cassette('purge_drops') do
      service.drops(filter: 'all').items.each do |drop|
        service.delete_drop(drop.href)
      end
    end
  end

  describe '#drops' do
    subject { VCR.use_cassette('list_drops') { service.drops }}
    before do
      VCR.use_cassette('setup_drops') do
        service.upload favicon
        service.bookmark 'http://cl.ly', private: false
        drop = service.bookmark 'http://getcloudapp.com', name: 'CloudApp'
        service.trash_drop drop.href
      end
    end

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'has 2 drops' do
      subject.should have(2).items
    end

    context 'with filter' do
      subject {
        VCR.use_cassette('list_drops_with_filter') {
          service.drops filter: 'trash'
        }
      }

      it 'returns the filtered drops' do
        subject.should have(1).items
      end
    end

    context 'with limit' do
      subject {
        VCR.use_cassette('list_drops_with_limit') {
          service.drops limit: 1
        }
      }

      it 'limits drops' do
        subject.should have(1).items
      end
    end

    context 'with href' do
      subject {
        VCR.use_cassette('list_drops_with_href') {
          @href = service.drops(limit: 1).link('next').href
          service.drops href: @href
        }
      }

      it 'returns the resource at the given href' do
        subject.link('self').href.should eq(@href)
      end
    end

    context 'with an empty href' do
      subject {
        VCR.use_cassette('list_drops_with_nil_href') {
          service.drops(href: nil)
        }
      }

      it 'has 2 drops' do
        subject.should have(2).items
      end
    end

    context 'with href and filter' do
      subject {
        VCR.use_cassette('list_drops_with_href_and_filter') {
          @href = service.drops(limit: 1).link('next').href
          service.drops href: @href, filter: 'trash'
        }
      }

      it 'ignores filter' do
        subject.should have(1).items
      end
    end

    context 'with href and limit' do
      subject {
        VCR.use_cassette('list_drops_with_href_and_limit') {
          @href = service.drops(limit: 1).link('next').href
          service.drops href: @href, limit: 42
        }
      }

      it 'ignores limit' do
        subject.should have(1).items
      end
    end

    context 'with a bad token' do
      let(:token) { 'wrong' }
      subject {
        VCR.use_cassette('list_drops_with_bad_token') {
          service.drops
        }
      }

      it { should be_unauthorized }
    end
  end

  describe '#drop_at' do
    subject {
      VCR.use_cassette('list_drops') {
        @href = service.drops.items.first.href
      }
      VCR.use_cassette('view_drop') { service.drop_at(@href) }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns a drop' do
      subject.should have(1).item
    end
  end

  describe '#update' do
    let(:url)     { 'http://getcloudapp.com' }
    let(:name)    { 'New Drop Name' }
    let(:private) { false }
    subject {
      VCR.use_cassette('rename_drop') {
        drop = service.bookmark(url).items.first
        service.update drop.href, name: name, private: private
      }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns the updated drop' do
      subject.should have(1).item
    end

    it 'updates the name' do
      subject.items.first.data['name'].should eq(name)
    end

    it 'updates the privacy' do
      subject.items.first.data['private'].should eq(private)
    end

    context 'updating bookmark link' do
      subject {
        VCR.use_cassette('update_drop_bookmark_url') {
          drop = service.bookmark(url).items.first
          service.update drop.href, url: 'http://example.org'
        }
      }

      it { should be_a(CloudApp::CollectionJson::Representation) }

      it 'returns the new drop' do
        subject.should have(1).item
      end
    end

    context 'updating file' do
      let(:options) {{ path: favicon }}
      subject {
        VCR.use_cassette('update_file') {
          drop = service.bookmark(url).items.first
          service.update drop.href, options
        }
      }

      it { should be_a(CloudApp::CollectionJson::Representation) }

      it 'returns the new drop' do
        subject.should have(1).item
      end
    end
  end

  describe '#bookmark' do
    let(:url) { 'http://getcloudapp.com' }
    subject {
      VCR.use_cassette('create_bookmark') { service.bookmark(url) }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns the new drop' do
      subject.should have(1).item
    end

    it 'bookmarks the url'

    context 'with a name' do
      let(:name) { 'New Bookmark' }
      subject {
        VCR.use_cassette('create_bookmark_with_name') {
          service.bookmark url, name: name
        }
      }

      it 'has the given name' do
        subject.items.first.data['name'].should eq(name)
      end
    end

    context 'with a privacy' do
      subject {
        VCR.use_cassette('create_bookmark_with_privacy') {
          service.bookmark url, private: false
        }
      }

      it 'is public' do
        subject.items.first.data['private'].should eq(false)
      end
    end
  end

  describe '#upload' do
    subject {
      VCR.use_cassette('upload_file') { service.upload(favicon) }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns the new drop' do
      subject.should have(1).item
    end

    context 'with a name' do
      let(:name) { 'New File' }
      subject {
        VCR.use_cassette('upload_file_with_name') {
          service.upload favicon, name: name
        }
      }

      it 'has the given name' do
        subject.items.first.data['name'].should eq(name)
      end
    end

    context 'with a privacy' do
      subject {
        VCR.use_cassette('upload_file_with_privacy') {
          service.upload favicon, private: false
        }
      }

      it 'is public' do
        subject.items.first.data['private'].should eq(false)
      end
    end

    describe 'too large file'
  end

  describe '#token_for_account' do
    let(:service)  { CloudApp::Service.new }
    let(:email)    { 'arthur@dent.com' }
    let(:password) { 'towel' }
    subject {
      VCR.use_cassette('token_for_account') {
        CloudApp::Service.new.token_for_account email, password
      }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns a single item' do
      subject.should have(1).item
    end

    it 'returns the token' do
      subject.items.first.data.should eq('token' => token)
    end

    context 'with bad credentials' do
      let(:password) { 'wrong' }
      subject {
        VCR.use_cassette('token_for_account_with_bad_credentials') {
          CloudApp::Service.new.token_for_account email, password
        }
      }

      it { should be_unauthorized }
    end
  end

  describe '#trash_drop' do
    subject {
      VCR.use_cassette('trash_drop') {
        drop = service.bookmark('http://getcloudapp.com').items.first
        service.trash_drop drop.href
      }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns the trashed drop' do
      subject.should have(1).item
    end

    it 'trashes the drop' do
      subject.items.first.data['trash'].should eq(true)
    end
  end

  describe '#recover_drop' do
    subject {
      VCR.use_cassette('recover_drop') {
        drop = service.bookmark('http://getcloudapp.com').items.first
        service.trash_drop   drop.href
        service.recover_drop drop.href
      }
    }

    it { should be_a(CloudApp::CollectionJson::Representation) }

    it 'returns the recovered drop' do
      subject.should have(1).item
    end

    it 'recovers the drop' do
      subject.items.first.data['trash'].should eq(false)
    end
  end

  describe '#delete_drop' do
    subject {
      VCR.use_cassette('delete_drop') {
        drop = service.bookmark('http://getcloudapp.com').items.first
        service.delete_drop drop.href
      }
    }

    it { should be_authorized }
  end
end
