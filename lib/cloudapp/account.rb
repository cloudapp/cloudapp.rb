require 'forwardable'

# Usage:
#
#   # Create a new service passing CloudApp account token:
#   account = CloudApp::Account.using_token token
#
#   # Newest drops
#   account.drops                   #=> Active drops
#   account.drops(filter: :active)  #=> Active drops
#   account.drops(filter: :trash)   #=> Trashed drops
#   account.drops(filter: :all)     #=> All active and trashed drops
#
#   # TODO: Newest 5 drops
#   account.drops limit: 5
#
#   # List specific page of drops:
#   page1 = account.drops
#   page2 = account.drops href: page1.link('next')
#   page1 = account.drops href: page2.link('previous')
#   page1 = account.drops href: page1.link('self')
#
#
#   # TODO: Create a bookmark:
#   account.create url: 'http://getcloudapp.com', name: 'CloudApp'
#
#   # TODO: Upload a file:
#   account.create path: #<Pathname>, name: 'Screen shot'
#
#   # TODO: Use a public (short) link for the new drop:
#   account.create url:     'http://getcloudapp.com',
#              name:    'CloudApp',
#              private: false
#
#   # TODO: Delete a drop:
#   account.drops.get(123).destroy
#
#   # TODO: Delete a drop from the trash:
#   account.trash.get(123).destroy
#
#   # TODO: Restore a drop from the trash:
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
