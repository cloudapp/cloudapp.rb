require 'helper'
require 'support/vcr'

require 'cloudapp/service'

describe CloudApp::Service do
  let(:service)  { CloudApp::Service.using_token token }
  let(:token)    { 'abc123' }
  let(:email)    { 'arthur@dent.com' }
  let(:password) { 'towel' }
  let(:favicon)  {
    Pathname('../../support/files/favicon.ico').expand_path(__FILE__)
  }

  after(:all) do
    VCR.use_cassette('purge_drops') do
      service.drops(filter: 'all').each do |drop|
        service.delete_drop(drop.href)
      end
    end
  end

  describe '.token_for_account' do
    subject {
      VCR.use_cassette('token_for_account') {
        CloudApp::Service.token_for_account email, password
      }
    }

    it 'returns the token' do
      subject.should be_a(String)
      subject.should eq(token)
    end

    context 'with bad credentials' do
      let(:password) { 'wrong' }
      subject {
        VCR.use_cassette('token_for_account_with_bad_credentials') {
          CloudApp::Service.token_for_account email, password
        }
      }

      it 'returns nothing' do
        subject.should be_nil
      end
    end
  end

  describe '#account_token' do
    subject {
      VCR.use_cassette('account_token') {
        CloudApp::Service.new.account_token email, password
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
          CloudApp::Service.new.account_token email, password
        }
      }

      it { should be_unauthorized }
    end
  end

  describe '#drops' do
    subject {
      VCR.use_cassette('list_drops') {
        service.upload favicon
        service.bookmark 'http://cl.ly'
        service.drops
      }
    }

    it { should be_a(CloudApp::DropCollection) }

    context 'with filter' do
      subject {
        VCR.use_cassette('list_drops_with_filter') {
          service.bookmark('http://cl.ly').first.trash
          service.drops filter: 'trash'
        }
      }

      it { should be_a(CloudApp::DropCollection) }

      it 'returns the filtered drops' do
        subject.first.should be_trashed
      end
    end

    context 'with limit' do
      subject {
        VCR.use_cassette('list_drops_with_limit') {
          service.drops limit: 1
        }
      }

      it { should be_a(CloudApp::DropCollection) }
      it { should have(1).item }
    end

    context 'with a bad token' do
      let(:token) { 'wrong' }
      subject {
        VCR.use_cassette('list_drops_with_bad_token') {
          service.drops
        }
      }

      it { should be_a(CloudApp::DropCollection) }
      it { should be_unauthorized }
    end
  end

  describe '#drop' do
    subject {
      VCR.use_cassette('view_drop') {
        drop = service.bookmark('http://cl.ly').first
        service.drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }
  end

  describe '#bookmark' do
    let(:url) { 'http://getcloudapp.com' }
    subject {
      VCR.use_cassette('create_bookmark') { service.bookmark(url) }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    context 'with a name' do
      let(:name) { 'New Bookmark' }
      subject {
        VCR.use_cassette('create_bookmark_with_name') {
          service.bookmark(url, name: name).first
        }
      }
      its(:name) { should eq(name) }
    end

    context 'with a privacy' do
      subject {
        VCR.use_cassette('create_bookmark_with_privacy') {
          service.bookmark(url, private: false).first
        }
      }
      it { should_not be_private }
    end
  end

  describe '#upload' do
    subject {
      VCR.use_cassette('upload_file') { service.upload(favicon) }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    context 'with a name' do
      let(:name) { 'New File' }
      subject {
        VCR.use_cassette('upload_file_with_name') {
          service.upload(favicon, name: name).first
        }
      }
      its(:name) { should eq(name) }
    end

    context 'with a privacy' do
      subject {
        VCR.use_cassette('upload_file_with_privacy') {
          service.upload(favicon, private: false).first
        }
      }
      it { should_not be_private }
    end

    describe 'too large file'
  end

  describe '#update' do
    let(:url)  { 'http://getcloudapp.com' }
    let(:name) { 'New Drop Name' }
    subject {
      VCR.use_cassette('rename_drop') {
        drop = service.bookmark(url).first
        service.update drop.href, name: name, private: false
      }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    it 'updates the name' do
      subject.first.name.should eq(name)
    end

    it 'updates the privacy' do
      subject.first.should_not be_private
    end

    context 'updating bookmark link' do
      subject {
        VCR.use_cassette('update_drop_bookmark_url') {
          drop = service.bookmark(url).first
          service.update drop.href, url: 'http://example.org'
        }
      }

      it { should be_a(CloudApp::DropCollection) }
      it { should have(1).item }
    end

    context 'updating file' do
      let(:options) {{ path: favicon }}
      subject {
        VCR.use_cassette('update_file') {
          drop = service.bookmark(url).first
          service.update drop.href, options
        }
      }

      it { should be_a(CloudApp::DropCollection) }
      it { should have(1).item }
    end
  end

  describe '#privatize_drop' do
    subject {
      VCR.use_cassette('privatize_drop') {
        drop = service.bookmark('http://getcloudapp.com', private: false).first
        service.privatize_drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    it 'privatizes the drop' do
      subject.first.should be_private
    end
  end

  describe '#publicize_drop' do
    subject {
      VCR.use_cassette('publicize_drop') {
        drop = service.bookmark('http://getcloudapp.com').first
        service.publicize_drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    it 'publicizes the drop' do
      subject.first.should_not be_private
    end
  end

  describe '#trash_drop' do
    subject {
      VCR.use_cassette('trash_drop') {
        drop = service.bookmark('http://getcloudapp.com').first
        service.trash_drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    it 'trashes the drop' do
      subject.first.should be_trashed
    end
  end

  describe '#recover_drop' do
    subject {
      VCR.use_cassette('recover_drop') {
        drop = service.bookmark('http://getcloudapp.com').first
        service.trash_drop   drop.href
        service.recover_drop drop.href
      }
    }

    it { should be_a(CloudApp::DropCollection) }
    it { should have(1).item }

    it 'recovers the drop' do
      subject.first.should_not be_trashed
    end
  end

  describe '#delete_drop' do
    it 'deletes the drop' do
      VCR.use_cassette('delete_drop') {
        @drop = service.bookmark('http://getcloudapp.com').first
        service.delete_drop @drop.href

        -> { service.drop @drop.href }.should raise_error(ArgumentError)
      }
    end
  end
end
