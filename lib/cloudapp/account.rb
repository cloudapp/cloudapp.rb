require 'forwardable'
require 'cloudapp/drop'
require 'cloudapp/drop_collection'

# Usage:
#
#   # Create a new service passing CloudApp account token:
#   account = CloudApp::Account.using_token token
#
#   # Newest drops
#   account.drops                  #=> Active drops
#   account.drops filter: :active  #=> Active drops
#   account.drops filter: :trash   #=> Trashed drops
#   account.drops filter: :all     #=> All active and trashed drops
#
#   # List specific page of drops:
#   page1 = account.drops
#   page2 = account.drops href: page1.link('next')      # Advance to page 2
#   page1 = account.drops href: page2.link('previous')  # Go back to page 1
#
#   # Newest 5 drops
#   account.drops limit: 5
#
#   # View specific drop:
#   account.drop_at drop.href
#
#   # Create a bookmark:
#   account.bookmark 'http://getcloudapp.com'
#   account.bookmark 'http://getcloudapp.com', name: 'CloudApp'
#   account.bookmark 'http://getcloudapp.com', private: false
#
#   # Upload a file:
#   account.upload #<Pathname>
#   account.upload #<Pathname>, name: 'Screen shot'
#   account.upload #<Pathname>, private: false
#
#   # Update a drop:
#   account.update drop.href, name: 'CloudApp'
#   account.update drop.href, private: false
#
#   # Trash a drop:
#   account.trash_drop 42
#
#   # Recover a drop from the trash:
#   account.recover_drop 42
#
#   # Delete a drop:
#   account.delete_drop 42
#
module CloudApp
  class Account
    extend Forwardable
    def_delegators :service, :delete_drop

    class << self
      attr_writer :service_source
    end

    def self.service_source
      @service_source ||= CloudApp::Service.public_method(:new)
    end

    def self.service
      service_source.call
    end

    def initialize(token = nil)
      @token = token
    end

    def self.using_token(token)
      CloudApp::Account.new token
    end

    def drops(*args)
      DropCollection.new service.drops(*args)
    end

    def drop_at(*args)
      DropCollection.new service.drop_at(*args)
    end

    def bookmark(*args)
      DropCollection.new service.bookmark(*args)
    end

    def upload(*args)
      DropCollection.new service.upload(*args)
    end

    def update(*args)
      DropCollection.new service.update(*args)
    end

    def trash_drop(*args)
      DropCollection.new service.trash_drop(*args)
    end

    def recover_drop(*args)
      DropCollection.new service.recover_drop(*args)
    end

  protected

    def service
      @service ||= self.class.service.tap do |service|
        service.token = @token if @token
      end
    end
  end
end
