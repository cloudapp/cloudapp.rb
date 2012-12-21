require 'cloudapp/collection_json/item'

module CloudApp
  module CollectionJson
    class Template < Item
      attr_reader :href

      def initialize item, href
        @href = href
        super item
      end

      def fill key, value
        return self unless data.has_key? key
        new_data = fetch('data').map {|datum|
          if datum.fetch('name') == key
            datum = datum.merge('value' => value)
          end
          datum
        }
        new_item = self.merge('data' => new_data)
        Template.new new_item, href
      end
    end
  end
end
