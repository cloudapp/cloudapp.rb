# Usage:
#
#   # Retrieve an account's token
#   token = CloudApp::Token.for_account 'arthur@dent.com', 'towel'
#
module CloudApp
  class Token
    class << self
      attr_writer :service_source

      def service_source
        @service_source ||= CloudApp::Service.public_method(:new)
      end

      def service
        service_source.call
      end
    end

    def self.for_account(email, password)
      service.token_for_account email, password
    end
  end
end
