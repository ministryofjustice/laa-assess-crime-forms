module ProviderData
  class ProviderDataClient
    def initialize
      @client = FeatureFlags.provider_api.enabled? ? ProviderDataApiClient.new : LocalDataClient.new
    end

    delegate :contracted_office_details, to: :@client
    delegate :office_details, to: :@client
  end
end
