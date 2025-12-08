module ProviderData
  class ProviderDataClient
    def initialize
      @client = Rails.env.production? ? ProviderDataApiClient.new : LocalDataClient.new
    end

    delegate :office_details, to: :@client
  end
end
