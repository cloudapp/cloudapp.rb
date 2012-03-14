module CloudApp
  module CollectionJson
    class Type
      def initialize(codec)
        @codec = codec
      end

      def encode(*args) raise('Collection+JSON encoding not implemented') end

      def decode(content_type, entity_body, options={})
        object = @codec.decode content_type, entity_body, options
        CollectionJson::Representation.new object
      end
    end
  end
end
