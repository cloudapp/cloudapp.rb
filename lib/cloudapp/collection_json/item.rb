require 'delegate'

module CloudApp
  module CollectionJson
    class Item < SimpleDelegator
      def href()    fetch('href')         end
      def rel()     fetch('rel')          end
      def code()    fetch('code', nil)    end
      def message() fetch('message', nil) end

      def links
        fetch('links', []).map {|link| Item.new(link) }
      end

      def link rel
        link = links.find {|link| link.rel == rel.to_s }
        link && link.href
      end

      def data
        data = {}
        fetch('data').each do |datum|
          data[datum.fetch('name')] = datum.fetch('value')
        end
        data
      end
    end
  end
end
