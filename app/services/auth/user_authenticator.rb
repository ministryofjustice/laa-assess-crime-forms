module Auth
  class UserAuthenticator
    STRATEGIES = {
      'azure_ad' => Strategies::AzureAd,
      'dev_auth' => Strategies::AzureAd,
      'silas' => Strategies::Silas
    }.freeze

    def self.call(auth_hash)
      new(auth_hash).call
    end

    def initialize(auth_hash, provider: Provider.current)
      @auth_hash = auth_hash
      @provider = provider
    end

    def call
      return Result.new(user: nil, failure_reason: :unsupported_provider) unless strategy
      return Result.new(user: nil, failure_reason: :provider_mismatch) unless provider.accepts_callback?(auth_hash.provider)

      strategy.new(auth_hash).call
    end

    private

    attr_reader :auth_hash, :provider

    def strategy
      STRATEGIES[Provider.normalise_callback_name(auth_hash.provider)]
    end
  end
end
