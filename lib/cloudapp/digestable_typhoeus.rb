require 'typhoeus'

class DigestableTyphoeus < Faraday::Adapter::Typhoeus
  def request(env)
    super.tap { |request| configure_authentication request, env }
  end

  def configure_authentication(request, env)
    authentication = request_options(env)[:authentication]

    request.auth_method = 'digest'
    request.username    = authentication[:username]
    request.password    = authentication[:password]
  end
end

Faraday.register_middleware :adapter, digestable_typhoeus: DigestableTyphoeus
