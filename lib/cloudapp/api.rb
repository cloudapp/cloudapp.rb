require 'forwardable'

# Usage:
#
#   # Retrieve an account's token
#   token = CloudApp::Api.token_for_account 'arthur@dent.com', 'towel'
#
#   # Create a new service passing CloudApp account token:
#   api = CloudApp::Api.using_token token
#
#   # Latest drops
#   api.drops
#
#   # Latest 5 drops
#   api.drops 5
#
#   # List all trashed drops:
#   api.trash
#
#   # List specific page of drops (not yet implemented):
#   page1 = api.drops
#   page2 = api.drops href: page1.href(:next)
#   page1 = api.drops href: page2.href(:previous)
#   page1 = api.drops href: page1.href(:self)
#
#   # Create a bookmark:
#   api.create url: 'http://getcloudapp.com', name: 'CloudApp'
#
#   # Upload a file:
#   api.create path: #<Pathname>, name: 'Screen shot'
#
#   # Use a public (short) link for the new drop:
#   api.create url:     'http://getcloudapp.com',
#              name:    'CloudApp',
#              private: false
#
#   # Delete a drop (not yet implemented):
#   api.drops.get(123).destroy
#
#   # Delete a drop from the trash (not yet implemented):
#   api.trash.get(123).destroy
#
#   # Restore a drop from the trash (not yet implemented):
#   api.trash.get(123).restore
#
module CloudApp
  class Api
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

    def self.token_for_account(email, password)
      drop_service.token_for_account email, password
    end

    def self.using_token(token)
      CloudApp::Api.new token
    end

  protected

    def drop_service
      @drop_service ||= self.class.drop_service.tap do |drop_service|
        drop_service.token = @token if @token
      end
    end
  end
end
