require 'ostruct'

module CloudApp
  class Drop < OpenStruct
    attr_accessor :href

    def initialize(collection_item)
      @href  = collection_item.href
      @links = collection_item.links
      super collection_item.data
    end

    def name()     super || share_url end
    def private?() private == true    end
    def public?() !private?           end

    def share_url
      link_for_relation 'canonical'
    end

    def thumbnail_url
      link_for_relation 'icon'
    end

  protected

    def link_for_relation(relation)
      link = @links.find {|link| link.rel == relation }
      link and link.href
    end
  end
end
