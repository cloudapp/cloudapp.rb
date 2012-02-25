require 'delegate'

module CloudApp
  class DropCollection < SimpleDelegator
    def initialize(response, drop_class = Drop)
      @response   = response
      @drop_class = drop_class
      super drops
    end

    def link(name)
      fallback = -> {}
      link = @response.link name, &fallback
      link and link.href.to_s
    end

  private

    def drops
      @drops ||= @response['items'].map {|drop| @drop_class.new(drop) }
    end
  end
end
