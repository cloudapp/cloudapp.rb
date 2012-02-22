require 'helper'

require 'cloudapp/api'

describe CloudApp::Api do
  let(:args)  { stub }
  let(:token) { 'token' }
  let(:drop_service)        { stub :drop_service, :token= => nil }
  let(:drop_service_source) { -> { drop_service }}
  before do CloudApp::Api.drop_service_source = drop_service_source end

  describe '.token_for_account' do
    let(:drop_service)  { stub :drop_service, token_for_account: token }
    let(:email)    { 'arthur@dent.com' }
    let(:password) { 'towel' }
    subject { CloudApp::Api.token_for_account(email, password) }

    it 'queries the drop service' do
      drop_service.should_receive(:token_for_account).with(email, password)
      subject
    end

    it 'returns the token' do
      subject.should eq(token)
    end
  end

  describe '.using_token' do
    it 'constructs and returns a new Api' do
      CloudApp::Api.should_receive(:new).with(token)
      CloudApp::Api.using_token(token)
    end
  end

  describe '#drops' do
    let(:drops) {[ stub(:drop) ]}
    before do drop_service.stub(drops: drops) end

    it 'delegates to the drop service' do
      drop_service.should_receive(:drops).with(args)
      CloudApp::Api.new(token).drops(args)
    end
  end

  describe '#trash' do
    let(:trash) {[ stub(:drop) ]}
    before do drop_service.stub(trash: trash) end

    it 'delegates to the service' do
      drop_service.should_receive(:trash).with(args)
      CloudApp::Api.new(token).trash(args)
    end
  end

  describe '#drop' do
    let(:drop_service) { stub :drop_service }
    let(:drop) { stub :drop }
    before do drop_service.stub(drop: drop) end

    it 'delegates to the service' do
      drop_service.should_receive(:drop).with(args)
      CloudApp::Api.new.drop(args)
    end
  end

  describe '#create' do
    it 'delegates to the service' do
      drop_service.should_receive(:create).with(args)
      CloudApp::Api.new.create(args)
    end
  end

  describe '#download' do
  end
end
