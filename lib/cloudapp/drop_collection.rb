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

    def unauthorized?
      @response == :unauthorized
    end

  private

    def drops
      return [] if unauthorized?
      @drops ||= @response.map {|drop| @drop_class.new(drop) }
    end
  end
end
