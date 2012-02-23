require 'helper'

require 'cloudapp/token'

describe CloudApp::Token do
  let(:drop_service_source) { -> { drop_service }}
  before do CloudApp::Token.drop_service_source = drop_service_source end

  describe '.for_account' do
    let(:drop_service)  { stub :drop_service, token_for_account: token }
    let(:token)         { 'token' }
    let(:email)         { 'arthur@dent.com' }
    let(:password)      { 'towel' }
    subject { CloudApp::Token.for_account(email, password) }

    it 'queries the drop service' do
      drop_service.should_receive(:token_for_account).with(email, password)
      subject
    end

    it 'returns the token' do
      subject.should eq(token)
    end
  end
end
