require "cloudapp/cli/collections"
require "cloudapp/credentials.rb"
require "http"

module CloudApp
  module CLI
    class CollectionsPrompt
      @@token = nil
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

            add_items collection_id slugs
                - add items by slug to an existing collection referenced by collection id. slugs should be a comma seperated list of slugs e.g. aa5095cc7812,0o022y3o363a,1R1B310N1V3n

            remove_items collection_id slugs
                - remove items by slug to an existing collection referenced by collection id. slugs should be a comma seperated list of slugs e.g. aa5095cc7812,0o022y3o363a,1R1B310N1V3n
            
            list_users collection_id
                - list all users with access to the collection 

            invite_user collection_id email_address role
                - invite a user to the collection referenced by collection_id. email_address is the address of the person to be invited. role should be either 'member' or 'admin'

            list_users collection_id access_id
                - remove a user from the collection referenced by collection_id. access_id is required.

            help
                - print this message
            
EOS
      end

      def self.parse_options(args)
        unless @@token
          @@token = CloudApp::CLI::Collections.token_to_jwt(Credentials.token)
        end
        @client = CloudApp::CLI::Collections.new(@@token)
        case args.arguments[0]
        when "list"
          @client.list_collections
        when "list_items"
          @client.list_items args.arguments[1]
        when "create"
          @client.create_collections args.arguments[1], args.arguments[2]
        when "delete"
          @client.delete_collection args.arguments[1]
        when "rename"
          @client.rename_collection args.arguments[1], args.arguments[2]
        when "add_items"
          @client.add_item_to_collection args.arguments[1], args.arguments[2]
        when "remove_items"
          @client.remove_item_from_collection args.arguments[1], args.arguments[2]
        when "list_users"
          @client.list_users args.arguments[1]
        when "invite_user"
          @client.invite_user args.arguments[1], args.arguments[2], args.arguments[3]
        when "remove_user"
          @client.remove_user args.arguments[1], args.arguments[2]
        else
          CloudApp::CLI::CollectionsPrompt.print_help
        end
      end
    end
  end
end
