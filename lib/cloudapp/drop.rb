require 'ostruct'
module CloudApp
  class Drop < OpenStruct
    def private?() private == true end
    def public? () !private?       end
  end
end
