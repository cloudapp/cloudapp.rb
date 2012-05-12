require 'delegate'
require 'forwardable'

module CloudApp
  class DropCollection < SimpleDelegator
    extend Forwardable
    def_delegators :@representation, :authorized?, :unauthorized?, :link, :links

    def initialize(representation, drop_class = Drop)
      @representation = representation
      @drop_class     = drop_class
      super drops
    end

  protected

    def drops
      @drops ||= @representation.items.map {|drop| @drop_class.new(drop) }
    end
  end
end
