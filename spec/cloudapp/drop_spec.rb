require 'helper'

require 'cloudapp/drop'

describe CloudApp::Drop do
  describe '#display_name' do
    describe 'a drop with a name' do
      let(:name) { stub :name }
      subject    { CloudApp::Drop.new name: name }

      it 'is its name' do
        subject.display_name.should eq(name)
      end
    end

    describe 'a drop with a redirect url and no a name' do
      let(:redirect_url) { stub :redirect_url }
      subject { CloudApp::Drop.new redirect_url: redirect_url }

      it 'is its redirect url' do
        subject.display_name.should eq(redirect_url)
      end
    end

    describe 'a drop with no redirect url and name' do
      let(:url) { stub :url }
      subject   { CloudApp::Drop.new url: url }

      it 'is its remote url' do
        subject.display_name.should eq(url)
      end
    end
  end

  describe '#private?' do
    describe 'a private drop' do
      subject { CloudApp::Drop.new private: true }

      it 'is true' do
        subject.private?.should eq(true)
      end
    end

    describe 'a public drop' do
      subject { CloudApp::Drop.new private: false }

      it 'is false' do
        subject.private?.should eq(false)
      end
    end
  end

  describe '#public?' do
    describe 'a private drop' do
      subject { CloudApp::Drop.new private: true }

      it 'is false' do
        subject.public?.should eq(false)
      end
    end

    describe 'a public drop' do
      subject { CloudApp::Drop.new private: false }

      it 'is true' do
        subject.public?.should eq(true)
      end
    end
  end
end
