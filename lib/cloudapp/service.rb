require 'leadlight'
require 'cloudapp/authorized'
require 'cloudapp/collection_json'
require 'mime/types'
require 'uri'

module CloudApp
  class Service
    USER_AGENT = "cloudapp-gem/#{CloudApp::VERSION} (#{RUBY_PLATFORM}) ruby/#{RUBY_VERSION}"

    Leadlight.build_service self do
      url 'https://api.getcloudapp.com'
      tints << CloudApp::CollectionJson::Tint
      tints << CloudApp::Authorized::Tint

      build_connection do |c|
        c.adapter :typhoeus
        c.headers[:user_agent] = CloudApp::Service::USER_AGENT
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

    def self.token_for_account email, password, &error_handler
      service = new
      service.on_error &error_handler if error_handler
      service.token_for_account(email, password)
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
        # TODO: Test unauthorized
        return representation.item
      end
    end

    def upload path
      template = drops_template.template.
                   fill('file_size', FileTest.size(path))
      post template.href, template.data do |representation|
        # TODO: Test unauthorized
        # TODO: Test too large files
        # TODO: Test uploading after free plan exhausted
        return upload_file(path, representation.template)
      end
    end

    def drops_template
      root.link('drops-template').get do |representation|
        # TODO: Test unauthorized
        return representation
      end
    end

  private

    def upload_file(path, template)
      file     = File.open path
      file_io  = Faraday::UploadIO.new file, mime_type_for(path)
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

    def mime_type_for path
      MIME::Types.type_for(File.basename(path)).first ||
        'application/octet-stream'
    end
  end
end
