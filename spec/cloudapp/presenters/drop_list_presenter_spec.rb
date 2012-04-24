require 'helper'
require 'stringio'

require 'cloudapp/presenters/drop_list_presenter'

class FakeDrop
  attr_accessor :name, :views, :href
  def initialize(options = {})
    @name  = options.fetch :name, 'Drop'
    @views = options.fetch :views, 0
    @href  = options.fetch :href, 'http://href'
  end
end

describe CloudApp::DropListPresenter do
  describe '#present' do
    let(:drops) {[ FakeDrop.new(name: 'one'), FakeDrop.new(name: 'two') ]}
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
      let(:drops) {[ FakeDrop.new(name: 'very long drop name'),
                     FakeDrop.new(name: 'short') ]}

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
