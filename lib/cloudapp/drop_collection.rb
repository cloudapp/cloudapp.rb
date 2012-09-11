require 'delegate'
require 'forwardable'

module CloudApp
  class DropCollection < SimpleDelegator
    extend Forwardable
    def_delegators :representation, :authorized?, :unauthorized?

    attr_reader :representation, :drop_class

    def initialize(representation, service, drop_class = Drop)
      @representation = representation
      @service        = service
      @drop_class     = drop_class
      super drops
    end

    def follow(relation)
      DropCollection.new representation.link(relation).follow, @service, drop_class
    end

    def has_link?(relation)
      !representation.link(relation) { nil }.nil?
    end

    def privatize(drop) @service.privatize_drop drop.href end
    def publicize(drop) @service.publicize_drop drop.href end
    def trash(drop)     @service.trash_drop drop.href     end
    def recover(drop)   @service.recover_drop drop.href   end
    def delete(drop)    @service.delete_drop drop.href    end

  protected

    def drops
      return [] if unauthorized?
      @drops ||= representation.items.map {|drop| drop_class.new(drop, self) }
    end
  end
end
