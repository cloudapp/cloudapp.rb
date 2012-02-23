require 'ostruct'

module CloudApp
  class Drop < OpenStruct
    def private?() private == true end
    def public?() !private? end

    def display_name
      name || redirect_url || url
    end

    def has_content?
      item_type != 'bookmark'
    end
  end
end
