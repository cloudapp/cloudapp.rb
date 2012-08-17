require 'helper'
require 'support/vcr'

require 'cloudapp/drop_content'

describe CloudApp::DropContent do
  describe '.download' do
    let(:content_url) { 'http://cl.ly/C23W/drop_presenter.rb' }
    let(:drop)        { stub :drop, content_url: content_url }
    subject {
      VCR.use_cassette('DropContent/download') {
        CloudApp::DropContent.download drop
      }
    }

    it 'downloads content' do
      expected = "require 'delegate'"
      subject[0...expected.size].should == expected
    end
  end
end
