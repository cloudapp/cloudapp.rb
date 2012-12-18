module CloudApp
  module CollectionJson
    Tint = Leadlight::Tint.new 'collection+json', status: [ :success, 401 ] do
      match_content_type 'application/vnd.collection+json'
      extend CloudApp::CollectionJson::Representation
    end

    module Representation
      extend Forwardable

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

      def_delegators :collection, :template, :item

      class Item < SimpleDelegator
        def links
          fetch('links', []).map {|link| Item.new(link) }
        end

        def link rel
          links.find {|link| link.rel == rel.to_s }.href
        end

        def href() fetch('href') end
        def rel()  fetch('rel')  end
        def data
          data = {}
          fetch('data').each do |datum|
            data[datum.fetch('name')] = datum.fetch('value')
          end
          data
        end
      end

      class Collection < Item
        def initialize representation
          super representation.fetch('collection')
        end

        def template() Template.new(fetch('template'), href) end
        def items
          fetch('items').map {|item| Item.new(item) }
        end

        def item
          items.first
        end
      end

      class Template < Item
        attr_reader :href

        def initialize item, href
          @href = href
          super item
        end

        def enctype() fetch('enctype') end

        def fill key, value
          return self unless data.has_key?(key)
          new_data = fetch('data').map {|datum|
            if datum.fetch('name') == key
              datum = datum.merge 'value' => value
            end
            datum
          }
          new_item = self.merge('data' => new_data)
          Template.new new_item, href
        end
      end
    end
  end
end
