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
    def_delegators :service, :drops, :trash, :drop, :create

    class << self
      attr_writer :service_source

      def service_source
        @service_source ||= CloudApp::Service.public_method(:new)
      end

      def service
        service_source.call
      end
    end

    def initialize(token = nil)
      @token = token
    end

    def self.using_token(token)
      CloudApp::Account.new token
    end

  protected

    def service
      @service ||= self.class.service.tap do |service|
        service.token = @token if @token
      end
    end
  end
end
