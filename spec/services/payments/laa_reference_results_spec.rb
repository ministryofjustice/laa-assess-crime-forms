require 'rails_helper'

RSpec.describe Payments::LaaReferenceResults do
  describe '.call' do
    subject(:service) { described_class.new }

    let(:params) { { query:, total_results: } }
    let(:query) { 'Anything' }
    let(:search_type) { :payments }
    let(:total_results) { 10 }
    let(:search_results) do
      {
        'data' => [
          {
            'payment_request_claim' => {
              'laa_reference' => 'LAA-ABC123',
              'client_last_name' => 'Smith'
            }
          },
          {
            'payment_request_claim' => {
              'laa_reference' => 'LAA-XYZ123',
              'client_last_name' => 'Jones'
            }
          },
        ]
      }
    end

    let(:app_store_client) { instance_double(AppStoreClient, search: search_results) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(app_store_client)
    end

    it 'returns formatted search results from app store' do
      results = service.call(search_type, query, total_results)
      expect(results.count).to eq 2
      expect(results.first.class).to eq Payments::LaaReference
      expect(results.first.value).to eq 'LAA-ABC123'
      expect(results.first.description).to eq 'LAA-ABC123 - Defendant SMITH'
    end
  end
end
