require 'leadlight'

module CloudApp
  module AuthorizedRepresentation
    Tint = Leadlight::Tint.new 'authorized', status: [ :success, 401 ] do
      extend AuthorizedRepresentation
    end

    def authorized?
      not unauthorized?
    end

    def unauthorized?
      __response__.status == 401
    end
  end
end
