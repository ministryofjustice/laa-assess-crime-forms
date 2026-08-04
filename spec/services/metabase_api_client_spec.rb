require 'rails_helper'
require 'request_store'

RSpec.describe MetabaseApiClient do
  let(:request_id) { 'A8B0EB88-EA9A-DCAB-8902-CD521F2D5F51' }
  let(:outbound_request_id) { 'nscc-assess-a8b0eb88ea9adcab8902cd521f2d5f51' }
  let(:response) { double(:response, code:, body:) }
  let(:code) { 200 }
  let(:body) { { some: :data }.to_json }
  let(:metabase_private_url) { 'http://some.url' }
  let(:card_id) { 1 }
  let(:start_date) { '2024-01-01' }
  let(:end_date) { '2024-01-31' }
  let(:api_key) { 'test-bearer-token' }

  describe '#download_question' do
    before do
      allow(described_class).to receive(:post).and_return(response)
      allow(ENV).to receive(:fetch).with('METABASE_PRIVATE_URL')
                                   .and_return(metabase_private_url)
      allow(ENV).to receive(:fetch).with('METABASE_API_KEY')
                                   .and_return(api_key)
    end

    it 'puts the message to the specified URL' do
      expect(described_class).to receive(:post).with("#{metabase_private_url}/api/card/#{card_id}/query/csv",
                                                     body: {
                                                       format_rows: false,
                                                       pivot_results: false,
                                                       parameters: [
                                                         {
                                                           type: 'date', target: ['variable', %w[template-tag start_date]],
                                                           value: start_date
                                                         },
                                                         {
                                                           type: 'date', target: ['variable', %w[template-tag end_date]],
                                                           value: end_date
                                                         }
                                                       ]
                                                     }.to_json,
                                                     headers: { 'X-API-Key': api_key })

      subject.download_question(card_id, start_date, end_date)
    end
  end
end
