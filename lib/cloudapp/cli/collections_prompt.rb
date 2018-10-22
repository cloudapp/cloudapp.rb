require "cloudapp/cli/collections"
require "pry"

module CloudApp
  module CLI
    class CollectionsPrompt
      COLLECTIONS_CLIENT = CloudApp::CLI::Collections.new("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJlbmdpbmUiLCJpYXQiOjE1MzkxOTQ1ODUsImF1ZCI6ImxvZ2lucHciLCJleHAiOjE1NDE3ODY1ODUsInN1YiI6MjM2NiwiY29udGV4dCI6eyJ1c2VyIjp7ImVtYWlsIjoiam9lQGNsLmx5IiwiYWRtaW4iOnRydWV9fX0.VEum5w2GirlOBmDhXii-JIPTzOtglGJg5U-gIToX_So")
      def self.print_help
        $stdout.puts <<EOS
            
            Usage:
                cloudapp --collections [options]
            
            Options:

            list 
                - list all collections

            list_items collection_id
                - list all items in collection where collection is referenced by collection_id

            create collection_name [is_public]
                - create a new collection where the collection name is collection_name, is_public is an optional value 
                this defaults to false, setting it true will make this collection public. 

            delete collection_id
                - delete the collection referenced by collection_id

            rename collection_id new_name
                - renames an existing collection referenced by collection id with the new_name provided

            add_items collection_id items_ids
                - add items by id to an existing collection referenced by collection id. item_ids should be a comma seperated list of ids e.g. 1,55,999,2098

            help
                - print this message
            
EOS
      end

      def self.parse_options(args)
        case args.arguments[0]
        when "list"
          COLLECTIONS_CLIENT.list_collections
        when "list_items"
          COLLECTIONS_CLIENT.list_items args.arguments[1]
        when "create"
          COLLECTIONS_CLIENT.create_collections args.arguments[1], args.arguments[2]
        when "delete"
          COLLECTIONS_CLIENT.delete_collection args.arguments[1]
        when "rename"
          COLLECTIONS_CLIENT.rename_collection args.arguments[1], args.arguments[2]
        when "add_items"
          COLLECTIONS_CLIENT.add_item_to_collection args.arguments[1], args.arguments[2]
        else
          CloudApp::CLI::CollectionsPrompt.print_help
        end
      end
    end
  end
end
