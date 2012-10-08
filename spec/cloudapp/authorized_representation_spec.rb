require 'helper'

require 'cloudapp/service/authorized_representation'

describe CloudApp::AuthorizedRepresentation do
  let(:representation) { stub :representation, __response__: response }
  let(:response)       { stub :response, status: status }
  let(:status)         { 200 }
  let(:href) { stub }
  subject    { representation }
  before do
    representation.extend CloudApp::AuthorizedRepresentation
  end

  describe '#authorized?' do
    it { should be_authorized }

    context 'unauthorized status' do
      let(:status) { 401 }
      it { should_not be_authorized }
    end
  end

  describe '#unauthorized?' do
    it { should_not be_unauthorized }

    context 'unauthorized status' do
      let(:status) { 401 }
      it { should be_unauthorized }
    end
  end
end
