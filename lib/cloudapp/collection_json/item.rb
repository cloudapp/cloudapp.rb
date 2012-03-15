require 'ostruct'

module CloudApp
  module CollectionJson
    class Item
      attr_reader :href, :links, :data
      def initialize(item_data)
        @href  = item_data.fetch('href',  nil)
        @links = item_data.fetch('links', []).map {|link| OpenStruct.new(link) }
        @data  = DataCollection.hash_from(item_data.fetch('data'))
      end
    end

    class DataCollection
      def self.hash_from(data)
        Hash[data.map {|datum| [ datum['name'], datum['value'] ]}]
      end
    end
  end
end
