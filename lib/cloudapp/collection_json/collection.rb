require 'cloudapp/collection_json/item'
require 'cloudapp/collection_json/template'

module CloudApp
  module CollectionJson
    class Collection < Item
      def initialize representation
        super representation.fetch('collection')
      end

      def item() items.first end
      def items
        fetch('items', []).map {|item| Item.new(item) }
      end

      def template
        Template.new(fetch('template'), href)
      end

      def error
        return unless has_key? 'error'
        Item.new(fetch('error'))
      end
    end
  end
end
