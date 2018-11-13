require "cloudapp/cli/collections"
require "cloudapp/credentials.rb"
require "http"
require "optparse"

module CloudApp
  module CLI
    class CollectionsPrompt
      @@token = nil
      def self.print_help
        $stdout.puts <<EOS
            
            Usage:
                cloudapp --collections [flags] [options]
            
            flags:

            -l, --list 
                - list all collections

            -v, --list_items [collection_id]
                - list all items in collection where collection is referenced by collection_id

            -c, --create [collection_name] [is_public]
                - create a new collection where the collection name is collection_name, is_public is an optional value 
                this defaults to false, setting it true will make this collection public. 

            -d, --delete [collection_id]
                - delete the collection referenced by collection_id

            -r, --rename [collection_id] [new_name]
                - renames an existing collection referenced by collection id with the new_name provided

            -a, --add_items [collection_id] [slugs]
                - add items by slug to an existing collection referenced by collection id. slugs should be a comma seperated list of slugs e.g. aa5095cc7812,0o022y3o363a,1R1B310N1V3n

            -x, --remove_items [collection_id] [slugs]
                - remove items by slug to an existing collection referenced by collection id. slugs should be a comma seperated list of slugs e.g. aa5095cc7812,0o022y3o363a,1R1B310N1V3n
            
            -u, --list_users [collection_id]
                - list all users with access to the collection 

            -i, --invite_user [collection_id] [email_address] [role]
                - invite a user to the collection referenced by collection_id. email_address is the address of the person to be invited. role should be either 'member' or 'admin'

            -u, --list_users [collection_id] [access_id]
                - remove a user from the collection referenced by collection_id. access_id is required.

            -h, --help
                - print this message
            
EOS
      end

      def self.print_error(given, needed)
        print_help
        puts ""
        puts "ERROR -- Missing Arguments"
        if given == 0
          puts "No required arguments have been provided, #{needed} required arguments were expected."
        elsif given == 1
          puts "Only #{given} required argument has been provided, #{needed} required arguments were expected."
        else
          puts "Only #{given} required argument(s) has been provided, #{needed} required arguments were expected."
        end
      end

      def self.correct_number_of_required_args?(args, required)
        if (args.arguments.count - 1) >= required
          return true
        end
        print_error (args.arguments.count - 1), required
        return false
      end

      def self.parse_options(args)
        unless @@token
          @@token = CloudApp::CLI::Collections.token_to_jwt(Credentials.token)
        end
        @client = CloudApp::CLI::Collections.new(@@token)
        parser = OptionParser.new do |opts|
          opts.on("-l", "--list", "") do
            @client.list_collections
          end

          opts.on("-v", "--list_items", "") do
            @client.list_items args.arguments[1] if correct_number_of_required_args?(args, 1)
          end

          opts.on("-c", "--create", "") do
            @client.create_collections args.arguments[1], args.arguments[2] if correct_number_of_required_args?(args, 2)
          end

          opts.on("-d", "--delete", "") do
            @client.delete_collection args.arguments[1] if correct_number_of_required_args?(args, 1)
          end

          opts.on("-r", "--rename", "") do
            @client.rename_collection args.arguments[1], args.arguments[2] if correct_number_of_required_args?(args, 2)
          end

          opts.on("-a", "--add_items", "") do
            @client.add_item_to_collection args.arguments[1], args.arguments[2] if correct_number_of_required_args?(args, 2)
          end

          opts.on("-x", "--remove_items", "") do
            @client.remove_item_from_collection args.arguments[1], args.arguments[2] if correct_number_of_required_args?(args, 2)
          end

          opts.on("-u", "--list_users", "") do
            @client.list_users args.arguments[1] if correct_number_of_required_args?(args, 1)
          end

          opts.on("-i", "--invite_user", "") do
            @client.invite_user args.arguments[1], args.arguments[2], args.arguments[3] if correct_number_of_required_args?(args, 3)
          end

          opts.on("-e", "--remove_user", "") do
            @client.remove_user args.arguments[1], args.arguments[2] if correct_number_of_required_args?(args, 2)
          end

          opts.on_tail("-h", "--help", "") do
            print_help
            exit
          end
        end
        unless ARGV.count > 0
          print_help
          exit
        end
        parser.parse(ARGV)
      end
    end
  end
end
