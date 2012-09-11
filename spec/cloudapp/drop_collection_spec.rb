require 'helper'
require 'ostruct'

require 'cloudapp/drop_collection'

describe CloudApp::DropCollection do
  let(:representation) { stub :representation, unauthorized?: false,
                                               items:         items }
  let(:service)        { stub :service }
  let(:items)          {[ stub(:item1), stub(:item2) ]}
  let(:drop_class)     { stub(:drop_class, new: :drop) }
  subject { CloudApp::DropCollection.new representation, service, drop_class }

  describe 'collection' do
    it 'is a collection of drops' do
      subject.size.should eq(2)
    end

    it 'decodes each drop' do
      items.each do |drop|
        drop_class.should_receive(:new).once.
          with(drop, kind_of(CloudApp::DropCollection))
      end
      subject
    end
  end

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

  describe '#follow' do
    let(:link_representation) {
      stub :link_representation, unauthorized?: false,
                                 items:         []
    }
    subject {
      CloudApp::DropCollection.
        new(representation, service, drop_class).
        follow('yes')
    }

    before do
      link = stub :link
      link.should_receive(:follow).once.and_return(link_representation)
      representation.should_receive(:link).once.and_return(link)
    end

    it { subject.should be_a(CloudApp::DropCollection) }
    its(:representation) { should eq(link_representation) }
    its(:drop_class)     { should eq(drop_class) }

    it 'passes along service' do
      service.should_receive(:trash_drop)
      subject.trash stub.as_null_object
    end
  end

  describe '#has_link?' do
    context 'with link' do
      before do
        representation.should_receive(:link).
          once.
          with('yes').
          and_return(stub(:link))
      end

      it 'returns false' do
        subject.has_link?('yes').should eq(true)
      end
    end

    context 'without link' do
      before do
        representation.should_receive(:link).
          once.
          with('no').
          and_yield
      end

      it 'returns true' do
        subject.has_link?('no').should eq(false)
      end
    end
  end

  describe '#privatize' do
    it 'privatizes the given drop' do
      href = stub :href
      service.should_receive(:privatize_drop).once.with(href)
      subject.privatize stub(:drop, href: href)
    end
  end

  describe '#publicize' do
    it 'publicizes the given drop' do
      href = stub :href
      service.should_receive(:publicize_drop).once.with(href)
      subject.publicize stub(:drop, href: href)
    end
  end

  describe '#trash' do
    it 'trashes the given drop' do
      href = stub :href
      service.should_receive(:trash_drop).once.with(href)
      subject.trash stub(:drop, href: href)
    end
  end

  describe '#recover' do
    it 'recovers the given drop' do
      href = stub :href
      service.should_receive(:recover_drop).once.with(href)
      subject.recover stub(:drop, href: href)
    end
  end

  describe '#delete' do
    it 'deletes the given drop' do
      href = stub :href
      service.should_receive(:delete_drop).once.with(href)
      subject.delete stub(:drop, href: href)
    end
  end

  describe '#delete'

  context 'unauthorized' do
    before do representation.stub(unauthorized?: true) end

    it { should be_empty }
  end
end
