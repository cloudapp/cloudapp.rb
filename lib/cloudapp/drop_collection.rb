require 'delegate'
require 'forwardable'

module CloudApp
  class DropCollection < SimpleDelegator
    extend Forwardable
    def_delegators :representation, :authorized?, :unauthorized?#, :link, :links

    attr_reader :representation, :drop_class

    def initialize(representation, drop_class = Drop)
      @representation = representation
      @drop_class     = drop_class
      super drops
    end

    def follow(relation)
      self.class.new representation.link(relation).follow, drop_class
    end

    def has_link?(relation)
      !representation.link(relation) { nil }.nil?
    end

  protected

    def drops
      return [] if unauthorized?
      @drops ||= representation.items.map {|drop| drop_class.new(drop) }
    end
  end
end
