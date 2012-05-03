require 'helper'
require 'stringio'

require 'cloudapp/presenters/drop_list_presenter'

class CloudApp::DropListPresenter
  class FakeDrop
    attr_accessor :name, :views, :href
    def initialize(options = {})
      @name  = options.fetch :name, 'Drop'
      @views = options.fetch :views, 0
      @href  = options.fetch :href, 'http://href'
    end
  end
end

describe CloudApp::DropListPresenter do
  let(:fake_drop_class) { CloudApp::DropListPresenter::FakeDrop }

  describe '#present' do
    let(:drops) {[ fake_drop_class.new(name: 'one'),
                   fake_drop_class.new(name: 'two') ]}
    subject     { CloudApp::DropListPresenter.new(drops).present }

    it 'prints the drops' do
      expected = <<-LIST.chomp
Name  Views  Href       
one   0      http://href
two   0      http://href
LIST

      subject.should eq(expected)
    end

    context 'unequal drop name lengths' do
      let(:drops) {[ fake_drop_class.new(name: 'very long drop name'),
                     fake_drop_class.new(name: 'short') ]}

      it 'adjusts column widths' do
        expected = <<-LIST.chomp
Name                 Views  Href       
very long drop name  0      http://href
short                0      http://href
LIST

        subject.should eq(expected)
      end
    end
  end
end
