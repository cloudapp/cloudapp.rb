require 'leadlight'

module CloudApp
  module Authorized
    Tint = Leadlight::Tint.new 'authorized', status: [ :success, 401 ] do
      extend CloudApp::Authorized::Representation
    end

    module Representation
      def unauthorized?() __response__.status == 401 end
      def authorized?()   not unauthorized? end
    end
  end
end
