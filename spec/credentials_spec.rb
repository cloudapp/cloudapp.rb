require 'cloudapp/credentials'

describe Credentials do
  describe '.token' do
    let(:netrc) { stub :netrc, :[] => %w( arthur@dent.com towel ) }
    subject { Credentials.token(netrc) }
    it { should eq 'towel' }
  end

  describe '#token' do
    let(:netrc) { stub :netrc, :[] => %w( arthur@dent.com towel ) }
    subject { Credentials.new(netrc).token }

    it { should eq 'towel' }

    it 'fetches token from netrc' do
      netrc.should_receive(:[]).with('api.getcloudapp.com').once
      subject
    end

    context 'without saved token' do
      let(:netrc) { stub :netrc, :[] => nil }
      it { should be_nil }
    end
  end

  describe '.save_token' do
    let(:netrc) { stub :netrc }

    it 'saves the token' do
      netrc.should_receive(:save).once.ordered
      Credentials.save_token 'new token', netrc
    end
  end

  describe '#save_token' do
    let(:netrc) { stub :netrc }
    subject { Credentials.new(netrc) }

    it 'saves the token' do
      credentials = [ 'api@getcloudapp.com', 'new token' ]
      netrc.should_receive(:[]=).with('api.getcloudapp.com', credentials)
        .once.ordered
      netrc.should_receive(:save).once.ordered
      subject.save_token 'new token'
    end

    it 'ignores a nil token' do
      netrc.should_not_receive(:[]=)
      netrc.should_not_receive(:save)
      subject.save_token nil
    end

    it 'ignores an empty token' do
      netrc.should_not_receive(:[]=)
      netrc.should_not_receive(:save)
      subject.save_token ''
      subject.save_token ' '
    end
  end
end
