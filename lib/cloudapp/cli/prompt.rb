# Lovingly borrowed from the heroku gem:
#   https://github.com/heroku/heroku/blob/master/lib/heroku/auth.rb
module CloudApp
  module CLI
    class Prompt
      def ask_for_credentials
        $stderr.puts "Sign into CloudApp."
        $stderr.print "Email: "
        email = ask
        $stderr.print "Password (typing will be hidden): "
        password = ask_for_password
        [ email, password ]
      end

      def ask() $stdin.gets.to_s.strip end
      def ask_for_password
        echo_off
        password = ask
        $stderr.puts
        echo_on
        return password
      end

      # This part gratuitously copied from hub.
      #   https://github.com/defunkt/hub/blob/master/lib/hub/github_api.rb#L399-L400
      NULL = defined?(File::NULL) ? File::NULL :
               File.exist?('/dev/null') ? '/dev/null' : 'NUL'

      def echo_on()  with_tty { system "stty echo 2>#{NULL}"  } end
      def echo_off() with_tty { system "stty -echo 2>#{NULL}" } end
      def with_tty(&block)
        return unless $stdin.isatty
        yield
      rescue
        # fails on windows
      end
    end
  end
end
