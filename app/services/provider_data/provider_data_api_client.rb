module ProviderData
  class ProviderDataApiClient
    include HTTParty

    base_uri ENV.fetch('PROVIDER_API_HOST')
    headers 'X-Authorization' => ENV.fetch('PROVIDER_API_KEY')
    format :json

    PROVIDER_API_EFFECTIVE_DATE_PARAM = ENV.fetch('PROVIDER_API_EFFECTIVE_DATE_PARAM', '01-01-2025').freeze

    class << self
      def office_details(office_code)
        query(
          :get,
          "/provider-offices/#{office_code}",
          {
            200 => ->(data) { { 'office' => data['office'], 'firm' => data['firm'] } },
            204 => nil
          }
        )
      end

      def contracted_office_details(office_code)
        # effective_date only used in UAT environment
        effective_date = HostEnv.uat? ? PROVIDER_API_EFFECTIVE_DATE_PARAM : nil
        # :nocov: Querying an external API
        params = {
          'areaOfLaw' => 'CRIME LOWER',
          'effectiveDate' => effective_date
        }.compact
        # :nocov:

        query(
          :head,
          "/provider-offices/#{office_code}/schedules?#{URI.encode_www_form(params)}",
          {
            200 => ->(data) { data['office'].merge('firm' => data['firm']) },
            204 => nil
          }
        )
      end

      private

      def query(method, endpoint, handlers)
        response = send(method, endpoint)
        unless handlers.key?(response.code)
          raise StandardError, "Unexpected status code #{response.code} when querying provider API endpoint #{endpoint}"
        end

        handler = handlers[response.code]
        handler.respond_to?(:call) ? handler.call(response.parsed_response) : handler
      end
    end
  end
end
