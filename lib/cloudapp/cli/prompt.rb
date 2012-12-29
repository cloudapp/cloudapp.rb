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

      def echo_on()  with_tty { system "stty echo" }  end
      def echo_off() with_tty { system "stty -echo" } end
      def with_tty(&block)
        return unless $stdin.isatty
        yield
      rescue
        # fails on windows
      end
    end
  end
end
