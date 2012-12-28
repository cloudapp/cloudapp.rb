require 'delegate'

module CloudApp
  module CollectionJson
    class Item < SimpleDelegator
      def href()    fetch('href')    end
      def rel()     fetch('rel')     end
      def message() fetch('message') end

      def links
        fetch('links', []).map {|link| Item.new(link) }
      end

      def link rel
        links.find {|link| link.rel == rel.to_s }.href
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
