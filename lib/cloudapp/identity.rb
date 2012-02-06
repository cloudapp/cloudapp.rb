module CloudApp
  class Identity
    attr_accessor :email, :password

    def initialize(email, password)
      @email    = email
      @password = password
    end

    def self.from_config(config)
      new(config.fetch(:email), config.fetch(:password))
    end
  end
end
