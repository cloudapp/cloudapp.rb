require 'leadlight'
require 'cloudapp/authorized'
require 'cloudapp/collection_json'
require 'mime/types'
require 'uri'
require 'json'

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

    def download url, path
      get url do |request|
        return unless request.__response__.success?
        data = JSON.parse(request.__response__.body)

        if ['name', 'remote_url'].all? { |k| data.key?(k) }
          name = data['name']
          remote_url = data['remote_url']

          return download_file(remote_url, name, path)
        end
      end
    end

    def upload path
      template = drops_template.template
                   .fill('file_size', FileTest.size(path))
                   .fill('name',      File.basename(path))
      post template.href, template.data do |representation|
        # TODO: Test unauthorized
        return unless representation.__response__.success?
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

    def download_file(url, name, path)
      uri = Addressable::URI.parse url
      path = File.join(path, name)

      conn = Faraday.new(url: uri) do |builder|
        builder.request :multipart
        builder.response :logger, logger
        builder.adapter :typhoeus
      end

      conn.get(uri.request_uri).on_complete do |env|
        File.open(path, 'wb') { |f| f.write(env[:body]) }
      end

      # faking a drop's link
      drop = Object.new
      drop.define_singleton_method('link') { |*args| path }
      drop
    end

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
