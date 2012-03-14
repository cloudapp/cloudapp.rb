require 'delegate'
require 'ostruct'

module CloudApp
  module CollectionJson
    class Representation < SimpleDelegator
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
    end
  end
end
