require 'helper'

require 'cloudapp/token'

describe CloudApp::Token do
  let(:service_source) { -> { service }}
  before do CloudApp::Token.service_source = service_source end

  describe '.for_account' do
    let(:email)          { 'arthur@dent.com' }
    let(:password)       { 'towel' }
    let(:service)        { stub :service, token_for_account: representation }
    let(:representation) { stub :representation, unauthorized?: unauthorized,
                                                 items: [ item ]}
    let(:unauthorized)   { false }
    let(:item)           { stub :item, data: { 'token' => token }}
    let(:token)          { 'token' }
    subject { CloudApp::Token.for_account(email, password) }

    it { should eq(token) }

    it 'queries the drop service' do
      service.should_receive(:token_for_account).with(email, password)
      subject
    end

    context 'with bad credentials' do
      let(:unauthorized) { true }
      it { should be_nil }
    end
  end
end
