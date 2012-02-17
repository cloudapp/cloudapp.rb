require 'faraday'
require 'logger'
require 'typhoeus'

module CloudApp
  class DropContent
    def initialize(drop)
      @content_url = drop.content_url
    end

    def self.download(drop)
      new(drop).content
    end

    def content(url = @content_url)
      connection.get(url) do |req|
        req.headers['Accept'] = 'application/json'
      end.on_complete do |env|
        location = env[:response]['location']
        if location
          return content(location)
        else
          return env[:body]
        end
      end
    end

    def connection
      Faraday.new do |builder|
        builder.adapter :typhoeus
      end
    end
  end
end
