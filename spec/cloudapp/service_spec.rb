require 'helper'
require 'support/vcr_rspec'

require 'cloudapp/service'

describe CloudApp::Service do
  let(:token) { 'abc123' }

  describe '#drops' do
    let(:service) { CloudApp::Service.using_token token }
    subject { VCR.use_cassette('Service/list_drops') { service.drops }}

    it 'has 20 drops' do
      subject.should have(18).items
    end

    context 'with filter' do
      let(:filter) { 'trash' }
      subject {
        VCR.use_cassette('Service/list_drops_with_filter') {
          service.drops filter: filter
        }
      }

      it 'returns the filtered drops' do
        subject.should have(19).items
      end
    end

    context 'with href' do
      let(:href) { 'http://api.getcloudapp.com/drops?page=2&per_page=10' }
      subject {
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: href
        }
      }

      it 'returns the resource at the given href' do
        subject.link('self').should eq(href)
      end
    end

    context 'with an empty href' do
      let(:href) { nil }
      subject {
        VCR.use_cassette('Service/list_drops_with_filter') {
          service.drops filter: 'trash'
        }
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: 'http://api.getcloudapp.com/drops?page=2&per_page=10'
        }
        VCR.use_cassette('Service/list_drops') {
          service.drops href: nil
        }
      }

      it 'has 20 drops' do
        subject.should have(18).items
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
        pending
        subject.should have(limit).items
      end
    end

    context 'with limit and href' do
      let(:href) { 'http://api.getcloudapp.com/drops?page=2&per_page=10' }
      subject {
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: href, limit: 1
        }
      }

      it 'ignores limit' do
        subject.should have(8).items
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

  describe '#token_for_account' do
    let(:service)  { CloudApp::Service.new }
    let(:email)    { 'arthur@dent.com' }
    let(:password) { 'towel' }
    subject {
      VCR.use_cassette('Service/token_for_account') {
        CloudApp::Service.new.token_for_account email, password
      }
    }

    it 'returns the token from the given account' do
      subject.value.should eql(token)
    end

    it 'is authorized' do
      subject.should_not be_unauthorized
    end

    it 'is successful' do
      subject.should be_successful
    end

    context 'with bad credentials' do
      let(:password) { 'wrong' }
      subject {
        VCR.use_cassette('Service/token_for_account_with_bad_credentials') {
          CloudApp::Service.new.token_for_account email, password
        }
      }

      it 'is unauthorized' do
        subject.should be_unauthorized
      end

      it 'is not successful' do
        subject.should_not be_successful
      end
    end
  end
end
