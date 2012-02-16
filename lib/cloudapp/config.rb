require 'pathname'
require 'singleton'
require 'yaml'

module CloudApp
  class Config
    def initialize(path = File.expand_path('~/.cloudapprc'))
      @path   = path
      @config = read_config
    end

    def token
      @config[:token]
    end

    def token=(token)
      if token
        @config[:token] = token
      else
        @config.delete :token
      end

      write_config
    end

  private

    def read_config
      return {} unless File.exist?(@path)
      File.open(@path) {|file| YAML.load(file) }
    end

    def write_config
      File.open(@path, 'w', 0600) {|file|
        YAML.dump @config, file
      }
    end
  end
end
