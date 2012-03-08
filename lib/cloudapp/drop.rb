require 'ostruct'

module CloudApp
  class Drop < OpenStruct
    def initialize(collection_item)
      @href  = nil
      @links = collection_item.links
      super collection_item.data
    end

    def name()     super || link   end
    def private?() private == true end
    def public?() !private?        end

    def link
      link_for_relation 'canonical'
    end

  protected

    def link_for_relation(relation)
      link = @links.find {|link| link.rel == relation }
      link and link.href
    end
  end
end
