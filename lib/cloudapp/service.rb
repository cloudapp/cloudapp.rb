require 'leadlight'
require 'cloudapp/drop'
require 'cloudapp/drop_collection'

module CloudApp
  class Service
    Leadlight.build_service(self) do
      url 'http://api2.getcloudapp.dev'
    end

    def initialize(*args)
      super
      logger.level = Logger::INFO
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
      root.link('/rels/authenticate').get do |response|
        form = response.dup
        form['email']    = email
        form['password'] = password

        response.link('self').post({}, form) do |response|
          return response['token']
        end
      end
    end

    def drops(options = {})
      href = options.fetch :href, '/'
      DropCollection.new drops_at(href)
    end

  private

    def drops_at(href)
      get(href) do |response|
        return :unauthorized if response.__response__.status == 401

        drops_link = response.link('/rels/drops') { nil }
        if drops_link
          return drops_at(drops_link.href)
        else
          return response
        end
      end
    end
  end
end
