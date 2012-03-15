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

      def items(item_source = default_item_source)
        collection.fetch('items').map do |item|
          item_source.call(item)
        end
      end

      # # Ultimately this API would be nice.
      # root.template('/rels/authenticate', email: email, password: password).
      #   post do |response|
      #     return response
      #   end
      def template(rel = nil, template_source = default_template_source)
        return unless collection.has_key?('template') or
                      collection.has_key?('templates')

        templates(template_source).find {|template| template.rel == rel }
      end

    protected

      def default_item_source
        CloudApp::CollectionJson::Item.public_method(:new)
      end

      def default_template_source
        CloudApp::CollectionJson::Template.public_method(:new)
      end

      def collection
        self.fetch('collection')
      end

      def templates(template_source)
        template_data = if collection.has_key?('template')
                          [ collection.fetch('template') ]
                        elsif collection.has_key?('templates')
                          collection.fetch('templates')
                        end

        template_data.map {|template|
          template_source.call(template)
        }
      end
    end
  end
end
