module CloudApp
  module CLI
    class Options
      def self.parse args
        options = {}
        if args.delete('--direct') || args.delete('-d')
          options[:direct] = true
        end
        options[:copy_link] = true unless args.delete('--no-copy')
        options[:help]      = args.delete('--help') || args.delete('-h')
        options[:version]   = args.delete('--version')
        options[:action]    = args.shift unless args.empty?
        options[:arguments] = args unless args.empty?

        Options.new options
      end

      attr_accessor :arguments
      def initialize options
        @copy_link = options.fetch :copy_link, false
        @direct    = options.fetch :direct,    false
        @help      = options.fetch :help,      false
        @version   = options.fetch :version,   false
        @action    = options.fetch :action,    nil
        @arguments = options.fetch :arguments, []
      end

      def copy_link?
        @copy_link
      end

      def link_type
        @direct && action != :bookmark ? :embed : :canonical
      end

      def action
        if @help or @action == 'help'
          :help
        elsif @version
          :version
        elsif @action == 'bookmark'
          :bookmark
        elsif @action == 'upload'
          :upload
        else
          :invalid
        end
      end
    end
  end
end
