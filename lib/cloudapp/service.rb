require 'leadlight'
require 'cloudapp/authorized'
require 'cloudapp/collection_json'
require 'uri'

module CloudApp
  class Service
    Leadlight.build_service self do
      url 'http://api.getcloudapp.com'
      tints << CloudApp::CollectionJson::Tint
      tints << CloudApp::Authorized::Tint

      build_connection do |c|
        c.adapter :typhoeus
      end
    end

    def initialize
      super
      logger.level = Logger::WARN
    end

    def self.using_token token
      service = new
      service.token = token
      service
    end

    def token= token
      connection.token_auth token
    end

    def self.token_for_account email, password
      new.token_for_account(email, password)
    end

    def token_for_account email, password
      template = root.template
                   .fill('email',    email)
                   .fill('password', password)
      post template.href, template.data do |representation|
        return unless representation.authorized?
        return representation.item.data.fetch('token')
      end
    end

    def bookmark url
      template = drops_template.template.
                   fill('bookmark_url', url)
      post template.href, template.data do |representation|
        return representation.item
      end
    end

    def upload path
      template = drops_template.template.
                   fill('file_size', FileTest.size(path))
      post template.href, template.data do |representation|
        return upload_file(path, representation.template)
      end
    end

    def drops_template
      root.link('drops-template').get do |representation|
        return representation
      end
    end

  private

    def upload_file(path, template)
      file     = File.open path
      file_io  = Faraday::UploadIO.new file, 'image/png'  # TODO: Use correct mime type
      template = template.fill('file', file_io)
      uri      = Addressable::URI.parse template.href

      conn = Faraday.new(url: uri.site) {|builder|
        builder.request  :multipart
        builder.response :logger, logger
        builder.adapter  :typhoeus
      }

      conn.post(uri.request_uri, template.data).on_complete do |env|
        location = Addressable::URI.parse env[:response_headers]['Location']
        get location do |upload_response|
          return upload_response.item
        end
      end
    end
  end
end
