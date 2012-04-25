require 'helper'

require 'cloudapp/drop'
stub_class :DropContent

describe CloudApp::Drop do
  let(:href)  { stub :href }
  let(:links) { [] }
  let(:data)  { {} }
  subject {
    CloudApp::Drop.new stub(:drop, href: href, links: links, data: data)
  }

  its(:href) { should eq(href) }

  describe '#data' do
    let(:data) {{ name: 'Drop' }}
    its(:data) { should eq(data) }

    context 'with string keys' do
      let(:data) {{ 'name' => 'Drop' }}
      its(:data) { should eq(data) }
    end
  end

  describe '#name' do
    let(:data) {{ name: 'Drop' }}
    its(:name) { should eq(data[:name]) }

    context 'when nil' do
      let(:data)  {{ name: nil }}
      let(:links) {[ stub(:link, rel: 'canonical', href: '/canonical') ]}

      it 'returns the share url' do
        subject.name.should eq('/canonical')
      end
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

  describe '#created' do
    let(:data) {{ created: '2012-04-01T00:00:00Z' }}
    it 'parses date' do
      expected = DateTime.new(2012, 4, 1)
      subject.created.should eq(expected)
    end
  end

  describe '#share_url' do
    let(:links) {[
      stub(:canonical, rel: 'canonical', href: '/canonical'),
      stub(:alternate, rel: 'alternate', href: '/alternate')
    ]}
    its(:share_url) { should eq('/canonical') }
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

  describe '#embed_url' do
    let(:links) {[
      stub(:canonical, rel: 'canonical', href: '/canonical'),
      stub(:embed,     rel: 'embed',     href: '/embed')
    ]}
    its(:embed_url) { should eq('/embed') }

    context 'without an embed link' do
      let(:links) {[ stub(:canonical, rel: 'canonical', href: '/canonical') ]}
      its(:embed_url) { should be_nil }
    end
  end

  describe '#download_url' do
    let(:links) {[
      stub(:canonical, rel: 'canonical', href: '/canonical'),
      stub(:download,  rel: 'download',  href: '/download')
    ]}
    its(:download_url) { should eq('/download') }

    context 'without an download link' do
      let(:links) {[ stub(:canonical, rel: 'canonical', href: '/canonical') ]}
      its(:download_url) { should be_nil }
    end
  end
end
