require 'helper'
require 'stringio'

require 'cloudapp/drop_presenter'

describe CloudApp::OldDropPresenter do
  describe '.print' do
    let(:waiting) { 'Bookmarking... ' }
    let(:result)  { 'http://cl.ly/abc123' }
    let(:action)  { -> { result }}
    let(:io)      { StringIO.new }

    describe 'a single line' do
      subject {
        CloudApp::OldDropPresenter.print(options, &action)
        io.tap(&:rewind).readlines
      }

      describe 'with no format' do
        let(:options) {{ on: io, waiting: waiting }}

        it 'pretty prints' do
          expected = [ waiting, result, "\n" ].join
          subject.first.should eq(expected)
        end
      end

      describe 'with no waiting message' do
        let(:options) {{ on: io, format: :pretty }}

        it 'prints only the result' do
          expected = [ result, "\n" ].join
          subject.first.should eq(expected)
        end
      end

      describe 'csv format' do
        let(:options) {{ on: io, waiting: waiting, format: :csv }}

        it 'omits the waiting message' do
          options[:format] = :csv
          expected = [ result, "\n" ].join
          subject.first.should eq(expected)
        end
      end
    end

    describe 'a table of data' do
      let(:columns) {{ name: 'Name', url: 'Link' }}
      let(:result) {
        [ stub(:result1, name: 'Stub 1', url: 'http://stub1.com'),
          stub(:result2, name: 'Stub 2', url: 'http://stub2.com') ]
      }
      let(:options) {{ on: io, format: format, columns: columns }}

      subject {
        CloudApp::OldDropPresenter.print(options, &action)
        io.tap(&:rewind).readlines
      }

      describe 'pretty format' do
        let(:format) { :pretty }

        it 'prints column headers' do
          subject.first.should eq("Name    Link            \n")
        end

        it 'prints table data' do
          subject.should have(3).items
          subject[1].should eq("Stub 1  http://stub1.com\n")
          subject[2].should eq("Stub 2  http://stub2.com\n")
        end

        it 'prints non-string values' do
          result << stub(:result3, name: 'Stub 3', url: 3)
          subject[3].should eq("Stub 3  3               \n")
        end
      end

      describe 'csv format' do
        let(:format) { :csv }

        it 'prints column headers' do
          subject.first.should eq("Name,Link\n")
        end

        it 'prints table data' do
          subject.should have(3).items
          subject[1].should eq("Stub 1,http://stub1.com\n")
          subject[2].should eq("Stub 2,http://stub2.com\n")
        end
      end
    end

    describe 'providing multiple formats' do
      let(:result) {{ pretty: 'pretty', csv: 'csv' }}
      subject {
        CloudApp::OldDropPresenter.print(options, &action)
        io.tap(&:rewind).readlines
      }

      describe 'pretty format' do
        let(:options) {{ on: io, format: :pretty }}

        it 'pretty prints' do
          subject.first.should eq("pretty\n")
        end
      end

      describe 'csv format' do
        let(:options) {{ on: io, format: :csv }}

        it 'prints csv' do
          subject.first.should eq("csv\n")
        end
      end

    end
  end
end
