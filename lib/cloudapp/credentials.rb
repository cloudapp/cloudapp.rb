# Taken from the heroku gem.
# https://github.com/heroku/heroku/blob/master/lib/heroku/auth.rb
require 'netrc'

class Credentials
  def self.token
    new.credentials.last
  end

  def netrc_path
    default = Netrc.default_path
    encrypted = default + ".gpg"
    if File.exists?(encrypted)
      encrypted
    else
      default
    end
  end

  def netrc
    @netrc ||= begin
      File.exists?(netrc_path) && Netrc.read(netrc_path)
    rescue => error
      if error.message =~ /^Permission bits for/
        perm = File.stat(netrc_path).mode & 0777
        abort("Permissions #{perm} for '#{netrc_path}' are too open. You should run `chmod 0600 #{netrc_path}` so that your credentials are NOT accessible by others.")
      else
        raise error
      end
    end
  end

  def credentials=(credentials) @credentials = credentials end
  def credentials()
    (@credentials ||= read_credentials) || ask_for_and_save_credentials
  end

  def read_credentials
    # TODO: convert legacy credentials to netrc
    # if File.exists?(legacy_credentials_path)
    #   @api, @client = nil
    #   @credentials = File.read(legacy_credentials_path).split("\n")
    #   write_credentials
    #   FileUtils.rm_f(legacy_credentials_path)
    # end

    # read netrc credentials if they exist
    self.credentials = netrc['api.getcloudapp.com'] if netrc
  end

  def write_credentials
    FileUtils.mkdir_p(File.dirname(netrc_path))
    FileUtils.touch(netrc_path)
    FileUtils.chmod(0600, netrc_path)
    netrc['api.getcloudapp.com'] = credentials
    netrc.save
  end

  def delete_credentials
    # TODO: delete legacy credentials
    # if File.exists?(legacy_credentials_path)
    #   FileUtils.rm_f(legacy_credentials_path)
    # end
    if netrc
      netrc.delete('api.getcloudapp.com')
      netrc.save
    end
    self.credentials = nil
  end

  def ask_for_and_save_credentials
    self.credentials = ask_for_credentials
    write_credentials
    credentials
  end

  def ask_for_credentials
    puts "Enter your CloudApp credentials."

    print "Email: "
    email = ask

    print "Password (typing will be hidden): "
    password = ask_for_password

    # TODO: Remove this dependency on Service.
    token = CloudApp::Service.token_for_account email, password
    unless token
      puts "Incorrect email or password."
      puts
      delete_credentials
      return ask_for_credentials
    end

    [ email, token ]
  end

  def ask() $stdin.gets.to_s.strip end
  def ask_for_password
    echo_off
    password = ask
    puts
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
