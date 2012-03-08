require 'helper'

require 'cloudapp/drop'
stub_class :DropContent

describe CloudApp::Drop do
  let(:links) { [] }
  let(:data)  { {} }
  subject { CloudApp::Drop.new stub(:drop, links: links, data: data) }

  describe '#name' do
    let(:data) {{ name: 'Drop' }}
    it 'returns the name' do
      subject.name.should eq(data[:name])
    end

    context 'when nil' do
      let(:data)  {{ name: nil }}
      let(:links) {[ stub(:link1, rel: 'canonical', href: '/canonical') ]}

      it 'returns the link' do
        subject.name.should eq('/canonical')
      end
    end
  end

  describe '#link' do
    let(:links) {[
      stub(:link1, rel: 'canonical', href: '/canonical'),
      stub(:link1, rel: 'alternate', href: '/alternate')
    ]}

    it 'returns the href for the canonical link' do
      subject.link.should eq('/canonical')
    end
  end

  describe '#private?' do
    describe 'a private drop' do
      let(:data) {{ private: true }}
      it { should be_private }
    end

    describe 'a public drop' do
      let(:data) {{ private: false }}
      it { should_not be_private }
    end
  end

  describe '#public?' do
    describe 'a private drop' do
      let(:data) {{ private: true }}
      it { should_not be_public }
    end

    describe 'a public drop' do
      let(:data) {{ private: false }}
      it { should be_public }
    end
  end
end
