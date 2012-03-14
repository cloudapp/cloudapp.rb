module CloudApp
  module CollectionJson
    class Item
      attr_reader :href, :links, :data
      def initialize(item)
        @href  = item.fetch('href',  nil)
        @links = item.fetch('links', []).map {|link| OpenStruct.new(link) }
        @data  = DataCollection.hash_from(item.fetch('data'))
      end
    end

    class DataCollection
      def initialize(data)
        @data = data
      end

      def self.hash_from(data)
        DataCollection.new(data).to_hash
      end

      def to_hash
        Hash[@data.map {|datum| [ datum['name'], datum['value'] ]}]
      end
    end
  end
end
