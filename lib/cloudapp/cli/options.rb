module CloudApp
  module CLI
    class Options
      def self.parse(args)
        options = {}
        unless args.include? "--collections"
          if args.delete("--direct") || args.delete("-d")
            options[:direct] = true
          end
          options[:copy_link] = true unless args.delete("--no-copy")
          options[:help] = args.delete("--help") || args.delete("-h")
          options[:version] = args.delete("--version")
        end
        options[:collections] = args.delete("--collections")
        options[:arguments] = args unless args.empty?

        Options.new options
      end

      attr_reader :arguments

      def initialize(options)
        @copy_link = options.fetch :copy_link, false
        @direct = options.fetch :direct, false
        @help = options.fetch :help, false
        @version = options.fetch :version, false
        @collections = options.fetch :collections, false
        @arguments = options.fetch :arguments, []
      end

      def copy_link?() @copy_link end
      def direct_link?() @direct end

      def action
        if @help or @arguments.first == "help"
          :help
        elsif @version
          :version
        elsif @collections
          :collections
        else
          :share
        end
      end
    end
  end
end
