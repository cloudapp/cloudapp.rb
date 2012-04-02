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
#   account.drop_at drop.href
#
#   # Create a bookmark:
#   account.bookmark 'http://getcloudapp.com'
#   account.bookmark 'http://getcloudapp.com', name: 'CloudApp'
#   account.bookmark 'http://getcloudapp.com', private: false
#
#   # TODO: Upload a file:
#   account.upload #<Pathname>
#   account.upload #<Pathname>, name: 'Screen shot'
#   account.upload #<Pathname>, private: false
#
#   # Move a list of drops to the trash:
#   account.trash [ 1, 2, 3 ]
#
#   # Recover a list of drops from the trash:
#   account.recover [ 1, 2, 3 ]
#
#   # TODO: Permanently delete a list of drops:
#   account.delete [ 1, 2, 3 ]
#
module CloudApp
  class Account
    extend Forwardable
    def_delegators :service, :drops, :drop_at, :bookmark, :trash, :recover

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
