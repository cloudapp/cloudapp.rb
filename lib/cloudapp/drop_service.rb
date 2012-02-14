require 'leadlight'
require 'addressable/uri'
require 'cloudapp/drop'

# Leadlight service for mucking about with drops in the CloudApp API.
#
# Usage:
#
#   # Retrieve an account's token
#   token = DropSerivce.retrieve_token 'arthur@dent.com', 'towel'
#
#   # Create a new service passing CloudApp account token:
#   service = DropSerivce.using_token token
#
#   # List all drops:
#   service.drops
#
#   # Create a bookmark:
#   service.create url: 'http://getcloudapp.com', name: 'CloudApp'
#
#   # Upload a file:
#   service.create path: #<Pathname>, name: 'Screen shot'
#
#   # Use a public (short) link for the new drop:
#   service.create url:     'http://getcloudapp.com',
#                  name:    'CloudApp',
#                  private: false
#
#   # List all trashed drops:
#   service.trash
#
#   # Delete a drop (not yet implemented):
#   service.drops.get(123).destroy
#
#   # Delete a drop from the trash (not yet implemented):
#   service.trash.get(123).destroy
#
#   # Restore a drop from the trash (not yet implemented):
#   service.trash.get(123).restore
#
module CloudApp
  class DropService

    # Rased when given credentials are incorrect.
    class UNAUTHORIZED < StandardError; end

    Leadlight.build_connection_common do |c|
      c.request :multipart
      c.request :url_encoded
      c.adapter :typhoeus
    end

    Leadlight.build_service(self) do
      url 'http://my.cl.ly'

      # Add links present in the response body.
      #   { links: { self: "...", next: "...", prev: "..." } }
      tint 'links' do
        match Hash
        match { key? 'links' }
        self['links'].each do |rel, href|
          add_link href, rel
        end
      end

      tint 'root' do
        match_path '/'
        add_link '/items?api_version=1.2', 'drops', 'List owned drops'
        add_link_template '/items?api_version=1.2&per_page={per_page=20}', 'paginated_drops'
        add_link_template '/items?api_version=1.2&per_page={per_page=20}&deleted=true', 'paginated_trash'
      end

      tint 'create' do
        match_path '/items'
        # use "#{__location__}/new" when api_version isn't required in the query
        # string.
        add_link '/items/new', 'create_file', 'Create a new file drop'
      end

      # Add a rel=child link for each item in the list.
      #   { items: [{ id: 123, href: "..."}] }
      tint 'drops' do
        match_path '/items'
        match { key? 'items' }
        add_link_set 'child', :get do
          self['items'].map do |item|
            { href: item['href'], title: item['id'] }
          end
        end
      end

      # Add convenience methods on a drop representation to destroy and restore
      # from the trash.
      tint 'drop' do
        match_template '/items/{id}'
        extend do
          def destroy
            link('self').delete.
              raise_on_error.submit_and_wait
          end

          def restore
            link('self').put({}, deleted: true, item: { deleted_at: nil }).
              raise_on_error.submit_and_wait
          end
        end
      end
    end

    def initialize(*args)
      super
      logger.level = Logger::WARN
    end

    def self.using_token(token)
      new.tap do |service|
        service.token = token
      end
    end

    def self.retrieve_token(email, password)
      new.token email, password
    end


    def token=(token)
      connection.token_auth token
    end

    def token(email, password)
      post('/account/token', {}, { email: email, password: password }).
        raise_on_error.submit_and_wait do |response|
          return response['token']
        end
    rescue MultiJson::DecodeError => e
      raise UNAUTHORIZED
    end

    def drops(count = 20)
      root.paginated_drops(per_page: count)['items'].map do |drop_data|
        Drop.new drop_data
      end
    rescue MultiJson::DecodeError => e
      raise UNAUTHORIZED
    end

    def trash(count = 20)
      root.paginated_trash(per_page: count)['items'].map do |drop_data|
        Drop.new drop_data
      end
    rescue MultiJson::DecodeError => e
      raise UNAUTHORIZED
    end

    def create(attributes)
      options = { item: {}}
      options[:item][:name]         = attributes[:name]    if attributes.key? :name
      options[:item][:redirect_url] = attributes[:url]     if attributes.key? :url
      options[:item][:private]      = attributes[:private] if attributes.key? :private

      if attributes.key? :path
        create_file attributes[:path], options
      else
        create_bookmark options
      end
    rescue MultiJson::DecodeError => e
      raise UNAUTHORIZED
    end

    protected

    def create_bookmark(options)
      root.link('drops').post({}, options).raise_on_error.
        submit_and_wait do |new_drop|
          return Drop.new new_drop
        end
    end

    def create_file(path, options)
      root.drops.link('create_file').get(options).raise_on_error.
        submit_and_wait do |details|
          uri     = Addressable::URI.parse details['url']
          file    = Faraday::UploadIO.new File.open(path), 'image/png'
          payload = details['params'].merge file: file

          conn = Faraday.new(url: uri.site) do |builder|
            builder.request :multipart
            builder.request :url_encoded
            builder.adapter :typhoeus
          end

          conn.post(uri.request_uri, payload).on_complete do |env|
            get(env[:response_headers]['Location']).raise_on_error.
              submit_and_wait {|new_drop| return Drop.new new_drop }
          end
        end
    end
  end
end
