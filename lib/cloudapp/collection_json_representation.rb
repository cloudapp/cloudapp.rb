require 'delegate'
require 'ostruct'

module CloudApp
  class CollectionJsonType
    def initialize(codec)
      @codec = codec
    end

    def encode(*args) raise('Collection+JSON encoding not implemented') end

    def decode(content_type, entity_body, options={})
      object = @codec.decode content_type, entity_body, options
      CollectionJsonRepresentation.new object
    end
  end

  class CollectionJsonRepresentation < SimpleDelegator
    def initialize(representation)
      super
    end

    def href
      collection.fetch('href')
    end

    def collection_links
      return [] unless collection.has_key?('links')
      collection.fetch('links').map {|link| OpenStruct.new(link) }
    end

    def items
      collection.fetch('items').map do |item|
        Item.new item
      end
    end

    def template
      return unless collection.has_key?('template')
      Item.new collection.fetch('template')
    end

  protected

    def collection
      self.fetch('collection')
    end

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
