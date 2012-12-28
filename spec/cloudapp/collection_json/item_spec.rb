require 'helper'
require 'cloudapp/collection_json/item'

describe CloudApp::CollectionJson::Item do
  subject { described_class.new(data) }

  describe '#href' do
    let(:data) {{ 'href' => 'http://getcloudapp.com' }}
    its(:href) { should eq 'http://getcloudapp.com' }
  end

  describe '#rel' do
    let(:data) {{ 'rel' => 'relation' }}
    its(:rel)  { should eq 'relation' }
  end

  describe '#message' do
    let(:data)    {{ 'message' => 'error!' }}
    its(:message) { should eq 'error!' }
  end

  describe '#links' do
    subject { described_class.new(data).links }
    let(:data)  {{ 'links' => [
                     { 'rel' => 'self', 'href' => 'http://self.com' },
                     { 'rel' => 'next', 'href' => 'http://next.com' }] }}

    it { should be_an Array }
    it { should have(2).items }

    it 'returns an array of Items' do
      subject.each do |item|
        item.should be_a described_class
      end

      item = subject.first
      item.rel.should eq 'self'
      item.href.should eq 'http://self.com'
    end

    context 'with no links' do
      let(:data) { {} }
      it { should be_empty }
    end
  end

  describe '#link' do
    subject { described_class.new(data).link('next') }
    let(:data)  {{ 'links' => [
                     { 'rel' => 'self', 'href' => 'http://self.com' },
                     { 'rel' => 'next', 'href' => 'http://next.com' }] }}

    it { should eq 'http://next.com' }
  end

  describe '#data' do
    let(:data) {{ 'data' => [{ 'name' => 'first_name', 'value' => 'Arthur' },
                             { 'name' => 'last_name',  'value' => 'Dent' }] }}
    its(:data) { should eq 'first_name' => 'Arthur', 'last_name' => 'Dent' }
  end
end
