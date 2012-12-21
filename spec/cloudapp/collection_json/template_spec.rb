require 'cloudapp/collection_json/template'

describe CloudApp::CollectionJson::Template do
  let(:template) { described_class.new(data, 'http://href.com') }
  subject { template }

  describe 'the template item' do
    let(:data) {{ 'data' => [
                    { 'name' => 'first_name', 'value' => '' },
                    { 'name' => 'last_name', 'value' => ''  } ]}}

    its(:href) { should eq 'http://href.com' }
    its(:data) { should eq 'first_name' => '', 'last_name' => '' }
  end

  describe '#fill' do
    let(:data) {{ 'data' => [
                    { 'name' => 'first_name', 'value' => '' },
                    { 'name' => 'last_name', 'value' => ''  } ]}}
    subject { template.fill('first_name', 'Arthur') }

    it { should be_a described_class }
    it { should_not eq template }

    it 'fills the datum' do
      subject.data.fetch('first_name').should eq 'Arthur'
    end

    context 'a nonexistent key' do
      it 'does nothing' do
        subject.fill('bad', 'value').should eq subject
      end
    end
  end
end
