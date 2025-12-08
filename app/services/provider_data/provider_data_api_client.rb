module ProviderData
  class ProviderDataApiClient
    include HTTParty

    base_uri ENV.fetch('PROVIDER_API_HOST')
    headers 'X-Authorization' => ENV.fetch('PROVIDER_API_KEY')
    format :json

    class << self
      def office_details(office_code)
        # :nocov: Querying an external API
        params = {
          'areaOfLaw' => 'CRIME LOWER'
        }
        # :nocov:

        query(
          :head,
          "/provider-offices/#{office_code}/schedules?#{URI.encode_www_form(params)}",
          {
            200 => ->(data) { data['office'] },
            204 => nil
          }
        )
      end

      private

      def query(method, endpoint, handlers, fallback = nil)
        response = send(method, endpoint)
        unless handlers.key?(response.code)
          return fallback if fallback

          raise "Unexpected status code #{response.code} when querying provider API endpoint #{endpoint}"
        end

        handler = handlers[response.code]
        handler.respond_to?(:call) ? handler.call(response.parsed_response) : handler
      end
    end
  end
end
