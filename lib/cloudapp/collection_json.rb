require 'cloudapp/collection_json/item'
require 'cloudapp/collection_json/collection'
require 'cloudapp/collection_json/template'

module CloudApp
  module CollectionJson
    Tint = Leadlight::Tint.new 'collection+json', status: [ :success, 401 ] do
      match_content_type 'application/vnd.collection+json'
      extend CloudApp::CollectionJson::Representation
    end

    module Representation
      extend Forwardable
      def_delegators :collection, :template, :item

      def self.extended representation
        Collection.new(representation).links.each do |link|
          representation.add_link link.href, link.rel
        end
      end

      def fill_template attributes
        collection.template.fill(attributes)
      end

      def collection
        Collection.new(self)
      end
    end
  end
end
