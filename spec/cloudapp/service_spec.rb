require 'helper'
require 'support/vcr_rspec'

require 'cloudapp/service'

describe CloudApp::Service do
  let(:token) { 'abc123' }

  describe '#drops' do
    let(:service) { CloudApp::Service.using_token token }
    subject { VCR.use_cassette('Service/list_drops') { service.drops }}

    it 'has 20 drops' do
      subject.should have(20).items
    end

    context 'with href' do
      let(:href) { 'http://api2.getcloudapp.dev/drops?page=2' }
      subject {
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: href
        }
      }

      it 'returns the resource at the given href' do
        subject.link('self').should eq(href)
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
      let(:href) { 'http://api2.getcloudapp.dev/drops?page=2' }
      subject {
        VCR.use_cassette('Service/list_drops_with_href') {
          service.drops href: href, limit: 1
        }
      }

      it 'ignores limit' do
        subject.should have(17).items
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
end
