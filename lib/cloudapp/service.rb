require 'leadlight'
require 'cloudapp/collection_json'
require 'cloudapp/collection_json/tint'
require 'cloudapp/drop'
require 'cloudapp/drop_collection'

module CloudApp
  class Service
    Leadlight.build_service(self) do
      url 'https://api.getcloudapp.com'
      tints << CollectionJson::Tint
    end

    Leadlight.build_connection_common do |builder|
      builder.adapter :typhoeus
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
      authenticate_response = root
      data = authenticate_response.template.
               fill('email' => email, 'password' => password)

      post(authenticate_response.href, {}, data) do |response|
        return response
      end
    end

    def drops(options = {})
      href   = options[:href] || :root
      params = options.has_key?(:href) ? {} : options
      DropCollection.new drops_at(href, params)
    end

    def drop_at(href)
      DropCollection.new drops_at(href)
    end

    def update(href, options = {})
      collection = drops_at href
      drop       = DropCollection.new(collection).first
      path       = options.fetch :path, nil
      attributes = drop.data.merge fetch_drop_attributes(options)
      data       = collection.template.fill attributes

      put(drop.href, {}, data) do |collection|
        if not path
          return DropCollection.new(collection)
        else
          return upload_file(path, collection)
        end
      end
    end

    def bookmark(url, options = {})
      attributes = fetch_drop_attributes options.merge(url: url)
      collection = drops_at :root
      data       = collection.template.fill(attributes)

      post(collection.href, {}, data) do |response|
        return DropCollection.new(response)
      end
    end

    def upload(path, options = {})
      attributes = fetch_drop_attributes options.merge(path: path)
      collection = drops_at :root
      data       = collection.template.fill(attributes)

      post(collection.href, {}, data) do |collection|
        return upload_file(path, collection)
      end
    end

    def trash_drop(href)
      update href, trash: true
    end

    def recover_drop(href)
      update href, trash: false
    end

    def delete_drop(href)
      delete(href) do |response|
        return SimpleResponse.new(response)
      end
    end

  private

    def drops_at(href, params = {})
      params = params.each_with_object({}) {|(key, value), params|
        params[key.to_s] = value
      }

      if href == :root
        get('/') do |response|
          return :unauthorized if response.__response__.status == 401
          href = response.link('drops').href
        end
      end

      get(href) do |response|
        return :unauthorized if response.__response__.status == 401
        if not params.empty?
          drops_query = response.query('drops-filter')
          href        = drops_query.href
          params      = drops_query.fill(params)
        else
          return response
        end
      end

      get(href, params) do |response|
        return :unauthorized if response.__response__.status == 401
        return response
      end
    end

    def fetch_drop_attributes(options)
      path = options.delete :path
      options[:file_size] = FileTest.size(path) if path
      { url:       'bookmark_url',
        file_size: 'file_size',
        name:      'name',
        private:   'private',
        trash:     'trash'
      }.each_with_object({}) {|(key, name), attributes|
        attributes[name] = options.fetch(key) if options.has_key?(key)
      }
    end

    def upload_file(path, collection)
      uri     = Addressable::URI.parse collection.href
      file    = File.open path
      file_io = Faraday::UploadIO.new file, 'image/png'
      fields  = collection.template.fill('file' => file_io)

      conn = Faraday.new(url: uri.site) {|builder|
        if collection.template.enctype == Faraday::Request::Multipart.mime_type
          builder.request :multipart
        end

        builder.response :logger, logger
        builder.adapter  :typhoeus
      }

      conn.post(uri.request_uri, fields).on_complete do |env|
        location = Addressable::URI.parse env[:response_headers]['Location']
        get(location) do |upload_response|
          return DropCollection.new(upload_response)
        end
      end
    end

    class SimpleResponse < SimpleDelegator
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
