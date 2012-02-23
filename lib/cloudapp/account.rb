require 'forwardable'

# Usage:
#
#   # Create a new service passing CloudApp account token:
#   account = CloudApp::Account.using_token token
#
#   # Latest drops
#   account.drops
#
#   # Latest 5 drops
#   account.drops 5
#
#   # List all trashed drops:
#   account.trash
#
#   # List specific page of drops (not yet implemented):
#   page1 = account.drops
#   page2 = account.drops href: page1.href(:next)
#   page1 = account.drops href: page2.href(:previous)
#   page1 = account.drops href: page1.href(:self)
#
#   # Create a bookmark:
#   account.create url: 'http://getcloudapp.com', name: 'CloudApp'
#
#   # Upload a file:
#   account.create path: #<Pathname>, name: 'Screen shot'
#
#   # Use a public (short) link for the new drop:
#   account.create url:     'http://getcloudapp.com',
#              name:    'CloudApp',
#              private: false
#
#   # Delete a drop (not yet implemented):
#   account.drops.get(123).destroy
#
#   # Delete a drop from the trash (not yet implemented):
#   account.trash.get(123).destroy
#
#   # Restore a drop from the trash (not yet implemented):
#   account.trash.get(123).restore
#
module CloudApp
  class Account
    extend Forwardable
    def_delegators :drop_service, :drops, :trash, :drop, :create

    class << self
      attr_writer :drop_service_source

      def drop_service_source
        @drop_service_source ||= CloudApp::Service.public_method(:new)
      end

      def drop_service
        drop_service_source.call
      end
    end

    def initialize(token = nil)
      @token = token
    end

    def self.using_token(token)
      CloudApp::Account.new token
    end

  protected

    def drop_service
      @drop_service ||= self.class.drop_service.tap do |drop_service|
        drop_service.token = @token if @token
      end
    end
  end
end
