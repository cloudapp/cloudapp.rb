require 'helper'
require 'support/vcr_rspec'

require 'cloudapp/service'

describe CloudApp::Service do
  let(:token) { 'abc123' }

  describe '#drops' do
    let(:limit)   { 3 }
    let(:service) { CloudApp::Service.using_token token }
    subject { VCR.use_cassette('Service/list_drops') { service.drops }}

    it 'has 20 drops' do
      subject.should have(20).items
    end

    context 'with filter' do
      let(:filter) { 'trash' }
      subject {
        VCR.use_cassette('Service/list_drops_with_filter') {
          service.drops filter: filter
        }
      }

      it 'returns the filtered drops' do
        subject.should have(2).items
      end
    end

    context 'with limit' do
      subject {
        VCR.use_cassette('Service/list_drops_with_limit') {
          service.drops limit: limit
        }
      }

      it 'returns the limited drops' do
        subject.should have(limit).items
      end
    end

    context 'with href' do
      subject {
        VCR.use_cassette('Service/list_drops_with_limit') {
          @href = service.drops(limit: limit).link('next').href
        }
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: @href
        }
      }

      it 'returns the resource at the given href' do
        subject.link('self').href.should eq(@href)
      end
    end

    context 'with an empty href' do
      subject {
        VCR.use_cassette('Service/list_drops') { service.drops(href: nil) }
      }

      it 'has 20 drops' do
        subject.should have(20).items
      end
    end

    context 'with filter and href' do
      subject {
        VCR.use_cassette('Service/list_drops_with_limit') {
          @href = service.drops(limit: limit).link('next').href
        }
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: @href, filter: 'trash'
        }
      }

      it 'ignores filter' do
        subject.should have(limit).items
      end
    end

    context 'with limit and href' do
      subject {
        VCR.use_cassette('Service/list_drops_with_limit') {
          @href = service.drops(limit: limit).link('next').href
        }
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: @href, limit: 1
        }
      }

      it 'ignores limit' do
        subject.should have(limit).items
      end
    end

    context 'with a bad token' do
      let(:token) { 'wrong' }
      subject {
        VCR.use_cassette('Service/list_drops_with_bad_token') {
          service.drops
        }
      }

      it 'is unauthorized' do
        subject.should be_unauthorized
      end
    end
  end

  describe '#drop_at' do
    let(:service) { CloudApp::Service.using_token token }
    subject {
      VCR.use_cassette('Service/list_drops') {
        @href = service.drops.items.first.href
      }
      VCR.use_cassette('Service/view_drop') { service.drop_at(@href) }
    }

    it 'returns a drop' do
      subject.should have(1).item
    end
  end

  describe '#update' do
    let(:service) { CloudApp::Service.using_token token }
    let(:url)     { 'http://getcloudapp.com' }
    let(:options) {{ name: name, private: private }}
    let(:name)    { 'New Drop Name' }
    let(:private) { false }
    subject {
      VCR.use_cassette('Service/rename_drop') {
        drop = service.bookmark(url).first
        service.update drop.href, options
      }
    }

    it { should be_a(CloudApp::DropCollection) }

    it 'returns the updated drop' do
      subject.should have(1).item
    end

    it 'updates the name' do
      subject.first.name.should eq(name)
    end

    it 'updates the privacy' do
      subject.first.private.should eq(private)
    end

    context 'updating bookmark link' do
      let(:options) {{ url: new_url }}
      let(:new_url) { 'http://example.org' }
      subject {
        VCR.use_cassette('Service/update_drop_bookmark_url') {
          drop = service.bookmark(url).first
          service.update drop.href, options
        }
      }

      it 'returns the new drop' do
        subject.should have(1).item
      end
    end

    context 'updating file' do
      let(:options) {{ path: path }}
      let(:path)    {
        Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
      }
      subject {
        VCR.use_cassette('Service/update_file') {
          drop = service.bookmark(url).first
          service.update drop.href, options
        }
      }

      it 'returns the new drop' do
        subject.should have(1).item
      end
    end
  end

  describe '#bookmark' do
    let(:service) { CloudApp::Service.using_token token }
    let(:url)     { 'http://getcloudapp.com' }
    subject {
      VCR.use_cassette('Service/create_bookmark') { service.bookmark(url) }
    }

    it { should be_a(CloudApp::DropCollection) }

    it 'returns the new drop' do
      subject.should have(1).item
    end

    context 'with a name' do
      let(:name) { 'New Bookmark' }
      subject {
        VCR.use_cassette('Service/create_bookmark_with_name') {
          service.bookmark url, name: name
        }
      }

      it 'has the given name' do
        subject.first.name.should eq(name)
      end
    end

    context 'with a privacy' do
      subject {
        VCR.use_cassette('Service/create_bookmark_with_privacy') {
          service.bookmark url, private: false
        }
      }

      it 'is public' do
        subject.first.private.should be_false
      end
    end
  end

  describe '#upload' do
    let(:service) { CloudApp::Service.using_token token }
    let(:path)    {
      Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
    }
    subject {
      VCR.use_cassette('Service/upload_file') { service.upload(path) }
    }

    it { should be_a(CloudApp::DropCollection) }

    it 'returns the new drop' do
      subject.should have(1).item
    end

    context 'with a name' do
      let(:name) { 'New File' }
      subject {
        VCR.use_cassette('Service/upload_file_with_name') {
          service.upload path, name: name
        }
      }

      it 'has the given name' do
        subject.first.name.should eq(name)
      end
    end

    context 'with a privacy' do
      subject {
        VCR.use_cassette('Service/upload_file_with_privacy') {
          service.upload path, private: false
        }
      }

      it 'is public' do
        subject.first.private.should be_false
      end
    end

    describe 'too large file'
  end

  describe '#token_for_account' do
    let(:service)  { CloudApp::Service.new }
    let(:email)    { 'arthur@dent.com' }
    let(:password) { 'towel' }
    subject {
      VCR.use_cassette('Service/token_for_account') {
        CloudApp::Service.new.token_for_account email, password
      }
    }

    it { should be_authorized }

    it 'returns a single item' do
      subject.should have(1).item
    end

    it 'returns the token' do
      subject.items.first.data.should eq('token' => token)
    end

    context 'with bad credentials' do
      let(:password) { 'wrong' }
      subject {
        VCR.use_cassette('Service/token_for_account_with_bad_credentials') {
          CloudApp::Service.new.token_for_account email, password
        }
      }

      it { should be_unauthorized }
    end
  end

  describe '#trash_drop' do
    let(:service) { CloudApp::Service.using_token token }
    subject {
      VCR.use_cassette('Service/trash_drop') {
        drop = service.bookmark('http://getcloudapp.com').first
        service.trash_drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }

    it 'returns the trashed drop' do
      subject.should have(1).item
    end

    it 'trashes the drop' do
      subject.first.trash.should eq(true)
    end
  end

  describe '#recover_drop' do
    let(:service) { CloudApp::Service.using_token token }
    subject {
      VCR.use_cassette('Service/recover_drop') {
        drop = service.bookmark('http://getcloudapp.com').first
        service.trash_drop   drop.href
        service.recover_drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }

    it 'returns the recovered drop' do
      subject.should have(1).item
    end

    it 'recovers the drop' do
      subject.first.trash.should eq(false)
    end
  end

  describe '#delete_drop' do
    let(:service) { CloudApp::Service.using_token token }
    subject {
      VCR.use_cassette('Service/delete_drop') {
        drop = service.bookmark('http://getcloudapp.com').first
        service.delete_drop drop.href
      }
    }

    it { should be_successful }
  end
end
