require 'helper'
require 'tempfile'

require 'cloudapp/config'

describe CloudApp::Config do
  let(:config)      { {} }
  let(:content)     { YAML.dump(config) }
  let(:path)        { config_file.path }
  let(:config_file) {
    Tempfile.new('cloudapprc', '.').tap do |file|
      file << content
      file.close
    end
  }

  describe '#new' do
    subject { CloudApp::Config.new path }

    describe 'an existing config file' do
      let(:config) {{ token: 'token' }}

      it 'reads the content' do
        subject.token.should eq(config[:token])
      end

      it 'updates a key' do
        new_token     = 'new token'
        subject.token = new_token
        expected      = YAML.dump token: new_token

        content = File.open(path) {|file| file.read }
        content.should eq(expected)
      end

      it 'clears a key' do
        subject.token = nil
        expected      = YAML.dump({})

        content = File.open(path) {|file| file.read }
        content.should eq(expected)
      end
    end

    describe 'an empty config file' do
      it 'returns nil' do
        subject.token.should be_nil
      end
    end

    describe 'a nonexistent config file' do
      let(:path) { 'nonexistent' }

      it 'returns nil' do
        subject.token.should be_nil
      end
    end
  end
end
