# Usage:
#
#   # Retrieve an account's token
#   token = CloudApp::Token.for_account 'arthur@dent.com', 'towel'
#
module CloudApp
  class Token
    class << self
      attr_writer :service_source
    end

    def self.service_source
      @service_source ||= CloudApp::Service.public_method(:new)
    end

    def self.service
      service_source.call
    end

    def self.for_account(email, password)
      representation = service.token_for_account email, password
      return if representation.unauthorized?

      representation.items.first.data['token']
    end
  end
end
