require 'leadlight'
require 'cloudapp/drop'
require 'cloudapp/drop_collection'
require 'cloudapp/collection_json'

module CloudApp
  class Service
    Leadlight.build_service(self) do
      url 'http://api.getcloudapp.com'

      type_mapping 'application/vnd.collection+json',
                   CollectionJson::Representation,
                   CollectionJson::Type

      tint 'collection+json' do
        match_content_type 'application/vnd.collection+json'
        collection_links.each do |link|
          add_link link.href, link.rel
        end
      end
    end

    def initialize(*args)
      super
      logger.level = Logger::WARN
    end

    def token=(token)
      connection.token_auth token
    end

    def self.using_token(token)
      new.tap do |service|
        service.token = token
      end
    end

    def token_for_account(email, password)
      Token.new request_token(email, password)
    end

    def drops(options = {})
      href   = options.fetch :href, '/'
      params = {}
      params[:filter] = options[:filter] if options.has_key?(:filter)
      DropCollection.new drops_at(href, params)
    end

  private

    # TODO: Only pass `params` to `/rels/drops` href.
    def drops_at(href, params)
      get(href, params) do |response|
        return :unauthorized if response.__response__.status == 401

        drops_link = response.link('/rels/drops') { nil }
        if drops_link
          return drops_at(drops_link.href, params)
        else
          return response
        end
      end
    end

    def request_token(email, password)
      authenticate_response = root

      # Refactor filling and posting template into CollectionJsonRepresentation
      template = authenticate_response.template
      template.data['email']    = email
      template.data['password'] = password

      post(authenticate_response.href, {}, template.data) do |response|
        return :unauthorized if response.__response__.status == 401
        return response.items.first.data['token']
      end
    end

    class Token < SimpleDelegator
      def value
        __getobj__
      end

      def successful?
        not unauthorized?
      end

      def unauthorized?
        self == :unauthorized
      end
    end
  end
end
