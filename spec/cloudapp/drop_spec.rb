require 'helper'

require 'cloudapp/drop'

describe CloudApp::Drop do
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
