# Usage:
#
#   # Retrieve an account's token
#   token = CloudApp::Token.for_account 'arthur@dent.com', 'towel'
#
module CloudApp
  class Token
    class << self
      attr_writer :drop_service_source

      def drop_service_source
        @drop_service_source ||= CloudApp::Service.public_method(:new)
      end

      def drop_service
        drop_service_source.call
      end
    end

    def self.for_account(email, password)
      drop_service.token_for_account email, password
    end
  end
end
