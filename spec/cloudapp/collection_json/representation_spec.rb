require 'helper'

require 'cloudapp/collection_json/representation'

describe CloudApp::CollectionJson::Representation do
  let(:href) { stub }
  let(:response) {{
    'collection' => {
      'href'  => href,
      'items' => []
    }
  }}

  subject { CloudApp::CollectionJson::Representation.new response }

  its(:href) { should eq(href) }
  its(:collection_links) { should be_empty }

  it 'has no items' do
    subject.items(stub(:item_source)).should be_empty
  end

  it 'has no templates' do
    subject.template(stub(:template_source)).should be_nil
  end

  context 'with collection links' do
    let(:links) {[
      { 'rel' => 'next', 'href' => '/next' },
      { 'rel' => 'prev', 'href' => '/prev' }
    ]}

    before do response['collection']['links'] = links end

    its(:collection_links) { should have(2).items }

    it 'presents links' do
      subject.collection_links.find {|link| link.rel == 'next' }.
        href.should eq('/next')
      subject.collection_links.find {|link| link.rel == 'prev' }.
        href.should eq('/prev')
    end
  end

  context 'with items' do
    let(:items)       {[ stub(:item1),      stub(:item2) ]}
    let(:item_data)   {[ stub(:item_data1), stub(:item_data2) ]}
    let(:item_source) { ->(item) {
      if item == item_data[0]
        items[0]
      elsif item == item_data[1]
        items[1]
      end
    }}

    before do response['collection']['items'] = item_data end

    it 'should have items' do
      subject.items(item_source).should eq(items)
    end
  end

  context 'with a template' do
    let(:template)        { stub :template }
    let(:template_data)   { stub :template_data }
    let(:template_source) { ->(item) {
      if item == template_data
        template
      end
    }}

    before do response['collection']['template'] = template_data end

    it 'finds the template' do
      subject.template(template_source).should eq(template)
    end
  end
end
