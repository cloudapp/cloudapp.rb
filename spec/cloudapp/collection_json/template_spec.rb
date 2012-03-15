require 'helper'
require 'cloudapp/collection_json/item'

require 'cloudapp/collection_json/template'

describe CloudApp::CollectionJson::Template do
  let(:template_data) {{ 'data' => [] }}
  subject { CloudApp::CollectionJson::Template.new template_data }

  its(:rel) { should be_nil }

  context 'with a rel' do
    let(:rel) { stub :rel }
    before do template_data['rel'] = rel end

    its(:rel) { should eq(rel) }
  end

  describe '#fill' do
    let(:email) { 'arthur@dent.com' }
    let(:template_data) {{
      'data' => [
        { 'name' => 'email', 'value' => '' },
        { 'name' => 'age',   'value' => 29 }
      ]
    }}

    it 'returns a filled template' do
      expected = { 'email' => email, 'age' => 29 }
      subject.fill('email' => email).should eq(expected)
    end

    it 'leaves data untouched' do
      subject.fill('email' => email)
      subject.data.should eq('email' => '', 'age' => 29)
    end
  end
end
