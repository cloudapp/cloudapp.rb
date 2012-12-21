require 'cloudapp/authorized'

describe CloudApp::Authorized::Representation do
  let(:representation) { stub :representation, __response__: response }
  let(:response)       { stub :response, status: status }
  subject { representation.extend described_class }

  context 'an unauthorized response' do
    let(:status) { 401 }
    it { should     be_unauthorized }
    it { should_not be_authorized }
  end

  context 'a success response' do
    let(:status) { 200 }
    it { should_not be_unauthorized }
    it { should     be_authorized }
  end
end
