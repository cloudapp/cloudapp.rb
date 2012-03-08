require 'helper'

require 'cloudapp/collection_json_representation'

describe CloudApp::CollectionJsonRepresentation do
  let(:href)  { stub }
  let(:items) { [] }
  let(:response) {
    {
      'collection' => {
        'href'  => href,
        'items' => items
      }
    }
  }

  subject { CloudApp::CollectionJsonRepresentation.new response }

  it 'has an href' do
    subject.href.should eq(href)
  end

  it 'has no collection links' do
    subject.collection_links.should be_empty
  end

  it 'has no items' do
    subject.items.should be_empty
  end

  it 'has no template' do
    subject.template.should be_nil
  end

  context 'with collection links' do
    let(:links) {[
      { 'rel' => 'next', 'href' => '/next' },
      { 'rel' => 'prev', 'href' => '/prev' }
    ]}

    before do
      response['collection']['links'] = links
    end

    it 'has collection links' do
      subject.collection_links.should have(2).items
    end

    it 'has link rels' do
      subject.collection_links[0].rel.should eq('next')
      subject.collection_links[1].rel.should eq('prev')
    end

    it 'has link hrefs' do
      subject.collection_links[0].href.should eq('/next')
      subject.collection_links[1].href.should eq('/prev')
    end
  end

  context 'with items' do
    let(:items) {
      [{
        'href'  => 'item1',
        'links' => [{ 'rel'  => 'canonical', 'href'  => 'link1' },
                    { 'rel'  => 'alternate', 'href'  => 'link2' }],
        'data'  => [{ 'name' => 'attr1',     'value' => 'value1' },
                    { 'name' => 'attr2',     'value' => 'value2' }]
      }, {
        'href' => 'item2',
        'links' => [{ 'rel'  => 'canonical', 'href'  => 'link3' },
                    { 'rel'  => 'alternate', 'href'  => 'link4' }],
        'data'  => [{ 'name' => 'attr3',     'value' => 'value3' },
                    { 'name' => 'attr4',     'value' => 'value4' }]
      }]
    }

    it 'has items' do
      subject.items.should have(2).items
    end

    it 'has item hrefs' do
      subject.items[0].href.should eq('item1')
      subject.items[1].href.should eq('item2')
    end

    it 'has item link rels' do
      expected = %w( canonical alternate )
      subject.items[0].links.map(&:rel).should eq(expected)
      subject.items[1].links.map(&:rel).should eq(expected)
    end

    it 'has item link hrefs' do
      subject.items[0].links.map(&:href).should eq(%w( link1 link2 ))
      subject.items[1].links.map(&:href).should eq(%w( link3 link4 ))
    end

    it 'has item data' do
      subject.items[0].data.should eq('attr1' => 'value1', 'attr2' => 'value2')
      subject.items[1].data.should eq('attr3' => 'value3', 'attr4' => 'value4')
    end
  end

  context 'with a template' do
    let(:template) {{
      'href' => 'template1',
      'data' => [{ 'name' => 'field1', 'value' => 'value1' },
                 { 'name' => 'field2', 'value' => 'value2' }]
    }}

    before do
      response['collection']['template'] = template
    end

    it 'has a template' do
      subject.template.should_not be_nil
    end

    it 'has an href' do
      subject.template.href.should eq('template1')
    end

    it 'has attributes' do
      subject.template.data['field1'].should eq('value1')
      subject.template.data['field2'].should eq('value2')
    end
  end

  context 'with no href' do
    let(:template) {{ 'data' => [] }}

    before do
      response['collection']['template'] = template
    end

    it 'has no href' do
      subject.template.href.should be_nil
    end
  end
end
