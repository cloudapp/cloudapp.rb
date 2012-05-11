require 'helper'
require 'ostruct'

require 'cloudapp/drop_collection'

describe CloudApp::DropCollection do
  let(:representation) { stub :representation, items: items }
  let(:items)          {[ stub(:item1), stub(:item2) ]}
  let(:drop_class)     { stub(:drop_class, new: nil) }
  subject { CloudApp::DropCollection.new representation, drop_class }

  describe '#authorized?' do
    let(:authorized) { stub :authorized }
    before do representation.stub(authorized?: authorized) end

    it 'delegates to representation' do
      subject.authorized?.should eq(authorized)
    end
  end

  describe '#unauthorized?' do
    let(:unauthorized) { stub :unauthorized }
    before do representation.stub(unauthorized?: unauthorized) end

    it 'delegates to representation' do
      subject.unauthorized?.should eq(unauthorized)
    end
  end

  it 'is a collection of drops' do
    subject.size.should eq(2)
  end

  it 'decodes each drop' do
    items.each do |drop|
      drop_class.should_receive(:new).with(drop)
    end
    subject
  end
end
