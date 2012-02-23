require 'helper'

require 'cloudapp/account'

describe CloudApp::Account do
  let(:args)  { stub }
  let(:token) { 'token' }
  let(:drop_service)        { stub :drop_service, :token= => nil }
  let(:drop_service_source) { -> { drop_service }}
  before do CloudApp::Account.drop_service_source = drop_service_source end

  describe '.using_token' do
    it 'constructs and returns a new Account' do
      CloudApp::Account.should_receive(:new).with(token)
      CloudApp::Account.using_token(token)
    end
  end

  describe '#drops' do
    let(:drops) {[ stub(:drop) ]}
    before do drop_service.stub(drops: drops) end

    it 'delegates to the drop service' do
      drop_service.should_receive(:drops).with(args)
      CloudApp::Account.new(token).drops(args)
    end
  end

  describe '#trash' do
    let(:trash) {[ stub(:drop) ]}
    before do drop_service.stub(trash: trash) end

    it 'delegates to the service' do
      drop_service.should_receive(:trash).with(args)
      CloudApp::Account.new(token).trash(args)
    end
  end

  describe '#drop' do
    let(:drop_service) { stub :drop_service }
    let(:drop) { stub :drop }
    before do drop_service.stub(drop: drop) end

    it 'delegates to the service' do
      drop_service.should_receive(:drop).with(args)
      CloudApp::Account.new.drop(args)
    end
  end

  describe '#create' do
    it 'delegates to the service' do
      drop_service.should_receive(:create).with(args)
      CloudApp::Account.new.create(args)
    end
  end

  describe '#download' do
  end
end
