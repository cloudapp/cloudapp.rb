require "http"
require "pry"
require "terminal-table"

module CloudApp
  module CLI
    class Collections
      COLLECTION_FIELDS = ["id", "name", "shared", "is_public", "created_at", "updated_at"]
      ITEM_FIELDS = ["id", "slug", "name", "item_type", "view_counter", "favorite", "share_url", "created_at", "updated_at"]

      attr_reader :http_client

      def self.token_to_jwt(token)
        http = HTTP.with(accept: "application/json", content_type: "application/json")
          .accept(:json)
        JSON.parse(http.post("https://my.cl.ly/v3/jwt_tokens?token=#{token}").body.readpartial)["jwt"]
      end

      def initialize(token)
        @BASE_URL = "https://my.cl.ly/v4/collections"
        http_client = HTTP.auth("Bearer #{token}")
          .with(accept: "application/json", content_type: "application/json")
          .accept(:json)
      end

      def list_collections
        resp = JSON.parse(http_client.get(@BASE_URL).body.readpartial)
        collections = []

        resp.each do |h|
          h.select! { |k, v| COLLECTION_FIELDS.include? k }
          collections << h.values
        end

        table = Terminal::Table.new :title => "Listing Collections", :headings => ["Collection ID", "Collection Name", "Shared", "Public", "Created At", "Updated At"], :rows => collections
        puts table
      end

      def list_items(collection_id)
        resp = JSON.parse(http_client.get("#{@BASE_URL}/#{collection_id}").body.readpartial)
        items = []
        resp["items"].each do |i|
          i.select! { |k, v| ITEM_FIELDS.include? k }
          items << i.values
        end
        table = Terminal::Table.new :title => "Listing Items in Collection `#{resp["name"]}`", :headings => ["Item Slug", "Item Name", "Created At", "Updated At", "Item Type", "Item View Count", "Item Share URL", "Item ID", "Item Favorited"], :rows => items
        puts table
      end

      def create_collections(name, public = false)
        public = public || false
        collection = {collection: {name: name, is_public: public}}
        JSON.parse(http_client.post(@BASE_URL, json: collection))
        self.list_collections
      end

      def delete_collection(id)
        JSON.parse(http_client.delete("#{@BASE_URL}/#{id}"))
        self.list_collections
      end

      def rename_collection(id, name)
        collection = {collection: {id: id, name: name}}
        http = http_client.put("#{@BASE_URL}/#{id}", json: collection)
        self.list_collections
      end

      def add_item_to_collection(id, slugs)
        slugs = slugs.split(",")
        slugs = slugs.map! { |i| i.strip }
        items = {slugs: slugs}
        http = http_client.post("#{@BASE_URL}/#{id}/items", json: items)
        self.list_items(id)
      end

      def remove_item_from_collection(id, slugs)
        slugs = slugs.split(",")
        slugs = slugs.map! { |i| i.strip }
        items = {slugs: slugs}
        http = http_client.delete("#{@BASE_URL}/#{id}/items", json: items)
        self.list_items(id)
      end

      def list_users(id)
        resp = JSON.parse(http_client.get("#{@BASE_URL}/#{id}").body.readpartial)
        members = []
        resp["members"].each do |i|
          members << [i["id"], i["email"], i["roles"][0]]
        end
        table = Terminal::Table.new :title => "Listing Members For `#{resp["name"]}` Collection", :headings => ["Access ID", "Member Email", "Role"], :rows => members
        puts table
      end

      def invite_user(id, email, role)
        payload = {"collection_id": id, "email": email, "roles": [role]}
        resp = JSON.parse(http_client.post("#{@BASE_URL}/#{id}/accesses", json: payload).body.readpartial)
        self.list_users(id)
      end

      def remove_user(id, access_id)
        resp = JSON.parse(http_client.delete("#{@BASE_URL}/#{id}/accesses/#{access_id}").body.readpartial)
        self.list_users(id)
      end
    end
  end
end
