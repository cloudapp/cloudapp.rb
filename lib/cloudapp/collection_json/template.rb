module CloudApp
  module CollectionJson
    class Template < Item
      attr_reader :rel, :enctype
      def initialize(template_data)
        super
        @rel     = template_data.fetch('rel',     nil)
        @enctype = template_data.fetch('enctype', nil)
      end

      def fill(template_data)
        template_data = template_data.select {|key| data.has_key?(key) }
        data.merge template_data
      end
    end
  end
end
