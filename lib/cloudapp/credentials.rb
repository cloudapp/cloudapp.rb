require 'netrc'

class Credentials
  attr_reader :netrc

  def initialize netrc
    @netrc = netrc
  end

  def self.token netrc = Netrc.read
    new(netrc).token
  end

  def self.save_token token, netrc = Netrc.read
    new(netrc).save_token token
  end

  def token
    credentials.last
  end

  def save_token token
    return if token.nil? or token =~ /^\s*$/
    netrc['api.getcloudapp.com'] = [ 'api@getcloudapp.com', token ]
    netrc.save
  end

private

  def credentials
    Array netrc['api.getcloudapp.com']
  end
end
