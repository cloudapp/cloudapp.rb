require "http"
require "pry"
require "terminal-table"

# v4_collection_items POST   /v4/collections/:collection_id/items(.:format)                         api/v4/collection_items#create {:format=>//}
#                    v4_collection_items DELETE /v4/collections/:collection_id/items(.:format)                         api/v4/collection_items#destroy {:format=>//}
#                 v4_collection_accesses POST   /v4/collections/:collection_id/accesses(.:format)                      api/v4/collection_accesses#create {:format=>//}
#                   v4_collection_access PUT    /v4/collections/:collection_id/accesses/:id(.:format)                  api/v4/collection_accesses#update {:format=>//}
#                                        DELETE /v4/collections/:collection_id/accesses/:id(.:format)                  api/v4/collection_accesses#destroy {:format=>//}
#                         v4_collections GET    /v4/collections(.:format)                                              api/v4/collections#index {:format=>//}
#                                        POST   /v4/collections(.:format)                                              api/v4/collections#create {:format=>//}
#                      new_v4_collection GET    /v4/collections/new(.:format)                                          api/v4/collections#new {:format=>//}
#                     edit_v4_collection GET    /v4/collections/:id/edit(.:format)                                     api/v4/collections#edit {:format=>//}
#                          v4_collection GET    /v4/collections/:id(.:format)                                          api/v4/collections#show {:format=>//}
#                                        PUT    /v4/collections/:id(.:format)                                          api/v4/collections#update {:format=>//}
#                                        DELETE /v4/collections/:id(.:format)                                          api/v4/collections#destroy {:format=>//}

module CloudApp
  module CLI
    class Collections
      COLLECTION_FIELDS = ["id", "name", "shared", "is_public", "created_at", "updated_at"]
      ITEM_FIELDS = ["id", "slug", "name", "item_type", "view_counter", "favorite", "share_url", "created_at", "updated_at"]

      def initialize(token)
        @BASE_URL = "https://my.vapor.ly/v4/collections"
        @HTTP = HTTP.auth("Bearer #{token}")
          .with(accept: "application/json", content_type: "application/json")
          .accept(:json)
      end

      def list_collections
        resp = JSON.parse(@HTTP.get(@BASE_URL).body.readpartial)
        collections = []

        resp.each do |h|
          h.select! { |k, v| COLLECTION_FIELDS.include? k }
          collections << h.values
        end

        table = Terminal::Table.new :title => "Listing Collections", :headings => ["Collection ID", "Collection Name", "Shared", "Public", "Created At", "Updated At"], :rows => collections
        puts table
      end

      def list_items(collection_id)
        resp = JSON.parse(@HTTP.get("#{@BASE_URL}/#{collection_id}").body.readpartial)
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
        JSON.parse(@HTTP.post(@BASE_URL, json: collection))
        self.list_collections
      end

      def delete_collection(id)
        JSON.parse(@HTTP.delete("#{@BASE_URL}/#{id}"))
        self.list_collections
      end

      def rename_collection(id, name)
        collection = {collection: {id: id, name: name}}
        http = @HTTP.put("#{@BASE_URL}/#{id}", json: collection)
        self.list_collections
      end

      def add_item_to_collection(id, item_ids)
        item_ids = item_ids.split(",")
        item_ids = item_ids.map! { |i| i.to_i }
        items = {item_ids: item_ids}
        puts items
        http = @HTTP.post("#{@BASE_URL}/#{id}/items", json: items)
        self.list_items(id)
      end

      def remove_item_from_collection(id, item_ids)
      end

      def get_share_link(id, private)
      end

      def list_users(id)
      end

      def invite_user(id, email)
      end

      def remove_user(id, email)
      end
    end
  end
end
