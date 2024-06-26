class AppStoreTokenAuthenticator
  class << self
    def call(headers)
      return true unless AppStoreTokenProvider.instance.authentication_configured?

      jwt = headers['Authorization'].gsub(/^Bearer /, '')
      data = parse(jwt)
      valid?(data)
    rescue StandardError
      false
    end

    private

    def parse(jwt)
      JWT.decode(jwt, nil, true, algorithms: 'RS256', jwks: jwks)
    end

    def valid?(data)
      data[0]['aud'] == app_store_client_id &&
        data[0]['iss'] == "https://login.microsoftonline.com/#{tenant_id}/v2.0" &&
        Time.zone.at(data[0]['exp']) > Time.zone.now
    end

    def jwks
      @jwks ||= JWT::JWK::Set.new(keys)
    end

    def keys
      HTTParty.get(jwks_uri)['keys']
    end

    def jwks_uri
      config_url = "https://login.microsoftonline.com/#{tenant_id}/.well-known/openid-configuration"
      HTTParty.get(config_url)['jwks_uri']
    end

    def tenant_id
      ENV.fetch('APP_STORE_TENANT_ID', 'UNDEFINED_APP_STORE_TENANT_ID')
    end

    def app_store_client_id
      ENV.fetch('APP_STORE_CLIENT_ID', 'UNDEFINED_APP_STORE_CLIENT_ID')
    end
  end
end
