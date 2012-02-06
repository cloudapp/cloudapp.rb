require 'helper'

require 'cloudapp/identity'

describe CloudApp::Identity do
  let(:email)    { 'arthur@dent.com' }
  let(:password) { 'towel' }

  describe '.initialize' do
    it 'accepts an email and password' do
      identity = CloudApp::Identity.new email, password

      identity.email   .should eq(email)
      identity.password.should eq(password)
    end
  end

  describe '.from_config' do
    let(:config) {{ email: email, password: password }}
    subject      { CloudApp::Identity.from_config config }

    it 'returns an identity' do
      subject.email   .should eq(email)
      subject.password.should eq(password)
    end
  end
end
