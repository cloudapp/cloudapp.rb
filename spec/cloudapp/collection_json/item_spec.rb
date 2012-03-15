require 'helper'

require 'cloudapp/collection_json/item'

describe CloudApp::CollectionJson::Item do
  let(:item_data) {{ 'data' => [] }}
  subject    { CloudApp::CollectionJson::Item.new item_data }

  its(:href)  { should be_nil }
  its(:links) { should be_empty }
  its(:data)  { should be_empty }

  context 'with an href' do
    let(:href) { stub :href }
    before do item_data['href'] = href end
    its(:href) { should eq(href) }
  end

  context 'with links' do
    let(:links) {[
      { 'rel'  => 'canonical', 'href'  => 'link1' },
      { 'rel'  => 'alternate', 'href'  => 'link2' }
    ]}
    before do item_data['links'] = links end

    its(:links) { should have(2).items }

    it 'presents links' do
      subject.links.find {|link| link.rel == 'canonical' }.
        href.should eq('link1')
      subject.links.find {|link| link.rel == 'alternate' }.
        href.should eq('link2')
    end
  end

  context 'with data' do
    let(:data) {[
      { 'name' => 'attr1', 'value' => 'value1' },
      { 'name' => 'attr2', 'value' => 'value2' }
    ]}
    before do item_data['data'] = data end

    its(:data) { should eq('attr1' => 'value1', 'attr2' => 'value2') }
  end
end
