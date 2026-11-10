class MetabaseApiClient < HttpClient
  def download_question(card_id, start_date, end_date)
    url = "/api/card/#{card_id}/query/csv"
    payload = search_params(start_date, end_date)
    response = self.class.post "#{host}#{url}", **options(payload)

    process_response(
      response,
      "Unexpected response from Metabase - status #{response.code} for '#{url}'",
      200 => ->(body) { body }
    )
  end

  def headers
    { 'X-API-Key': ENV.fetch('METABASE_API_KEY') }
  end

  def host
    ENV.fetch('METABASE_PRIVATE_URL')
  end

  private

  # rubocop:disable-next Metrics/MethodLength
  def search_params(start_date, end_date)
    {
      format_rows: false,
      pivot_results: false,
      parameters: [
        {
          type: 'date',
          target: ['variable', %w[template-tag start_date]],
          value: start_date
        },
        {
          type: 'date',
          target: ['variable', %w[template-tag end_date]],
          value: end_date
        }
      ]
    }
  end
end
