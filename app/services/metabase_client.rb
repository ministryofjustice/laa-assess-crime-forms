class MetabaseClient
  # :nocov:
  include HTTParty

  headers 'Content-Type' => 'application/json'

  def download_question(card_id, start_date, end_date)
    url = "/api/card/#{card_id}/query/csv"
    payload = search_params(start_date, end_date)
    response = self.class.post "#{host}#{url}", **options(payload)

    process_response(
      response,
      "Unexpected response from Metabase - status #{response.code} for '#{url}'",
      200 => ->(body) { body },
    )
  end

  private

  # rubocop:disable Metrics/MethodLength
  def search_params(start_date, end_date)
    {
      format_rows: false,
        pivot_results: false,
        parameters: [
          {
            type: 'date',
              target: [
                'variable',
                %w[template-tag start_date]
              ],
              value: start_date
          },
          {
            type: 'date',
              target: [
                'variable',
                %w[template-tag end_date]
              ],
              value: end_date
          }
        ]
    }
  end
  # rubocop:enable Metrics/MethodLength

  def options(payload = nil)
    options = payload ? { body: payload.to_json } : {}
    options.merge(headers:)
  end

  def headers
    { 'X-API-Key': ENV.fetch('METABASE_API_KEY', 'default_api_key') }
  end

  def host
    ENV.fetch('METABASE_SITE_URL', 'http://localhost:8000')
  end

  def process_response(response, error_message, response_maps)
    outcome = response_maps.detect { _1[0] == response.code || (_1[0].is_a?(Range) && _1[0].include?(response.code)) }&.last

    raise error_message unless outcome

    if outcome.respond_to?(:call)
      outcome.call(response.body)
    else
      outcome
    end
  end
  # :nocov:
end
