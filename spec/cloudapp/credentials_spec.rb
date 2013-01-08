require 'helper'
require 'cloudapp/credentials'

describe Credentials do
  describe '.token' do
    let(:netrc) { stub :netrc, :[] => %w( arthur@dent.com towel ) }
    let(:label) { stub :label }
    subject { Credentials.token(netrc, label) }
    it { should eq 'towel' }
  end

  describe '#token' do
    let(:netrc) { stub :netrc, :[] => %w( arthur@dent.com towel ) }
    let(:label) { stub :label }
    subject { Credentials.new(netrc, label).token }

    it { should eq 'towel' }

    it 'fetches token from netrc' do
      netrc.should_receive(:[]).with(label).once
      subject
    end

    context 'without saved token' do
      let(:netrc) { stub :netrc, :[] => nil }
      it { should be_nil }
    end
  end

  describe '.save' do
    let(:netrc) { stub :netrc, :[]= => nil }
    let(:label) { stub :label }

    it 'saves the token' do
      netrc.should_receive(:save).once.ordered
      Credentials.save 'login', 'new token', netrc, label
    end
  end

  describe '#save' do
    let(:netrc) { stub :netrc }
    let(:label) { stub :label }
    let(:login) { stub :login }
    subject { Credentials.new(netrc, label) }

    it 'saves the token' do
      credentials = [ 'arthur@dent.com', 'new token' ]
      netrc.should_receive(:[]=).with(label, credentials)
        .once.ordered
      netrc.should_receive(:save).once.ordered
      subject.save *credentials
    end

    it 'ignores a nil login' do
      netrc.should_not_receive(:[]=)
      netrc.should_not_receive(:save)
      subject.save nil, 'new token'
    end

    it 'ignores an empty login' do
      netrc.should_not_receive(:[]=)
      netrc.should_not_receive(:save)
      subject.save '', 'new token'
      subject.save ' ', 'new token'
    end

    it 'ignores a nil token' do
      netrc.should_not_receive(:[]=)
      netrc.should_not_receive(:save)
      subject.save login, nil
    end

    it 'ignores an empty token' do
      netrc.should_not_receive(:[]=)
      netrc.should_not_receive(:save)
      subject.save login, ''
      subject.save login, ' '
    end
  end
end
