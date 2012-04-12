require 'helper'

require 'cloudapp/account'

describe CloudApp::Account do
  let(:args)    { stub :args }
  let(:token)   { 'token' }
  let(:service) { stub :service, :token= => nil }
  let(:service_source) { -> { service }}
  before do CloudApp::Account.service_source = service_source end

  describe '.using_token' do
    it 'constructs and returns a new Account' do
      CloudApp::Account.should_receive(:new).with(token)
      CloudApp::Account.using_token(token)
    end
  end

  describe '#drops' do
    let(:drops) {[ stub(:drop) ]}
    subject { CloudApp::Account.new(token).drops(args) }
    before do service.stub(drops: drops) end

    it 'delegates to the drop service' do
      service.should_receive(:drops).with(args)
      subject
    end

    it 'returns the drops' do
      subject.should eq(drops)
    end
  end

  describe '#drop_at' do
    let(:drop) { stub :drop }
    subject { CloudApp::Account.new(token).drop_at(args) }
    before do service.stub(drop_at: drop) end

    it 'delegates to the drop service' do
      service.should_receive(:drop_at).with(args)
      subject
    end

    it 'returns the drop' do
      subject.should eq(drop)
    end
  end

  describe '#update' do
    let(:drop) { stub :drop }
    subject { CloudApp::Account.new(token).update(args) }
    before do service.stub(update: drop) end

    it 'delegates to the drop service' do
      service.should_receive(:update).with(args)
      subject
    end

    it 'returns the drop' do
      subject.should eq(drop)
    end
  end

  describe '#recover' do
    let(:drop_ids) { stub :drop_ids }

    it 'delegates to the service' do
      service.should_receive(:recover).with(args)
      CloudApp::Account.new(token).recover(args)
    end
  end

  describe '#trash' do
    let(:drop_ids) { stub :drop_ids }

    it 'delegates to the service' do
      service.should_receive(:trash).with(args)
      CloudApp::Account.new(token).trash(args)
    end
  end

  describe '#bookmark' do
    it 'delegates to the service' do
      service.should_receive(:bookmark).with(args)
      CloudApp::Account.new.bookmark(args)
    end
  end

  describe '#upload' do
    it 'delegates to the service' do
      service.should_receive(:upload).with(args)
      CloudApp::Account.new.upload(args)
    end
  end

  describe '#download' do
  end
end
