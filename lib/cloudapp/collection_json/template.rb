module CloudApp
  module CollectionJson
    class Template < Item
      attr_reader :rel
      def initialize(template_data)
        super
        @rel = template_data.fetch('rel',   nil)
      end

      def fill(template_data)
        data.merge template_data
      end
    end
  end
end
