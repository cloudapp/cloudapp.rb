require 'helper'
require 'cloudapp/collection_json/collection'

describe CloudApp::CollectionJson::Collection do
  let(:collection) { described_class.new(data) }
  subject { collection }

  describe 'the collection item' do
    let(:data) {{ 'collection' => { 'href' => 'http://href.com' }}}
    its(:href) { should eq 'http://href.com' }
  end

  describe '#items' do
    let(:data) {{
      'collection' => {
        'items' => [
          { 'href' => 'http://one.com' },
          { 'href' => 'http://two.com' } ]}
    }}
    subject { collection.items }

    it { should be_an Array }
    it { should have(2).items }

    it 'returns an array of Items' do
      subject.each do |item|
        item.should be_an CloudApp::CollectionJson::Item
      end

      item = subject.first
      item.href.should eq 'http://one.com'
    end

    context 'with no items' do
      let(:data) {{ 'collection' => {} }}
      it { should be_empty }
    end
  end

  describe '#item' do
    let(:data) {{
      'collection' => {
        'items' => [
          { 'href' => 'http://one.com' },
          { 'href' => 'http://two.com' } ]}}}
    subject { collection.item }

    it { should eq collection.items.first }

    context 'with no items' do
      let(:data) {{ 'collection' => {} }}
      it { should be_nil }
    end
  end

  describe '#template' do
    let(:data) {{
      'collection' => {
        'href' => 'http://href.com',
        'template' => {
          'data' => [
            { 'name' => 'first_name', 'value' => '' },
            { 'name' => 'last_name', 'value' => '' } ]}}}}
    subject { collection.template }

    it { should be_an CloudApp::CollectionJson::Template }
    its(:href) { should eq 'http://href.com' }
    its(:data) { should eq 'first_name' => '', 'last_name' => '' }
  end

  describe '#error' do
    let(:data) {{
      'collection' => {
        'error' => { 'message' => 'error!' }}}}
    subject { collection.error }

    it { should be_an CloudApp::CollectionJson::Item }
    its(:message) { should eq 'error!' }

    context 'with no error' do
      let(:data) {{ 'collection' => {} }}
      it { should be_nil }
    end
  end
end
