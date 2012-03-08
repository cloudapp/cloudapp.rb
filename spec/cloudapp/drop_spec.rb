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
      let(:links) {[ stub(:link, rel: 'canonical', href: '/canonical') ]}

      it 'returns the link' do
        subject.name.should eq('/canonical')
      end
    end
  end

  describe '#link' do
    let(:links) {[
      stub(:canonical, rel: 'canonical', href: '/canonical'),
      stub(:alternate, rel: 'alternate', href: '/alternate')
    ]}

    it 'returns the href for the canonical link' do
      subject.link.should eq('/canonical')
    end
  end

  describe '#thumbnail_url' do
    let(:links) {[
      stub(:canonical, rel: 'canonical', href: '/canonical'),
      stub(:icon,      rel: 'icon',      href: '/icon')
    ]}

    its(:thumbnail_url) { should eq('/icon') }

    context 'without an icon link' do
      let(:links) {[ stub(:canonical, rel: 'canonical', href: '/canonical') ]}
      its(:thumbnail_url) { should be_nil }
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
