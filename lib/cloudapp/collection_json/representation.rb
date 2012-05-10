require 'ostruct'

module CloudApp
  module CollectionJson
    module Representation
      def authorized?
        not unauthorized?
      end

      def unauthorized?
        __response__.status == 401
      end

      def href
        collection.fetch('href')
      end

      def collection_links
        return [] unless collection.has_key?('links')
        collection.fetch('links').map {|link| OpenStruct.new(link) }
      end

      def items(item_source = default_item_source)
        collection.fetch('items').map {|item|
          item_source.call(item)
        }
      end

      # Ultimately this API would be nice:
      #
      #   root.template(email: email, password: password).
      #     post do |response|
      #       return response
      #     end
      #
      # The Command Pattern could be nice as well. Template#[] may be a better
      # solution than faux methods.
      #
      #   root.create do |template|
      #     template.email = email
      #     template.password = password
      #   end
      #
      # Updates also use the template.
      #
      #   root.items.first.update do |template|
      #     template.name.reverse!
      #   end
      def template(template_source = default_template_source)
        return unless collection.has_key?('template')
        template_source.call collection.fetch('template')
      end

      def queries(query_source = default_query_source)
        return unless collection.has_key?('queries')
        collection.fetch('queries').map {|query| query_source.call(query) }
      end

      def query(rel, query_source = default_query_source)
        Array(queries(query_source)).find {|query| query.rel == rel }
      end

    protected

      def default_item_source
        CloudApp::CollectionJson::Item.public_method(:new)
      end

      def default_template_source
        CloudApp::CollectionJson::Template.public_method(:new)
      end

      def default_query_source
        CloudApp::CollectionJson::Template.public_method(:new)
      end

      def collection
        self.fetch('collection')
      end
    end
  end
end
