require 'ostruct'
module CloudApp
  class Drop < OpenStruct
    def private?() private == true end
    def public? () !private?       end

    def display_name
      name || redirect_url || url
    end

    def content
      DropContent.download content_url
    end
  end
end
