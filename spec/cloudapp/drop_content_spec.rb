require 'helper'
require 'support/vcr_rspec'

require 'cloudapp/drop_content'

describe CloudApp::DropContent do
  describe '.download' do
    let(:content_url) { 'http://cl.ly/C23W/drop_presenter.rb' }
    subject {
      VCR.use_cassette('DropContent/download') {
        CloudApp::DropContent.download content_url
      }
    }

    it 'downloads content' do
      expected = "require 'delegate'"
      subject[0...expected.size].should == expected
    end
  end
end
