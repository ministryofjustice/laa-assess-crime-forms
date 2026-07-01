require 'rails_helper'

RSpec.describe Payments::DownloadController, :stub_oauth_token do
  describe 'GET #index' do
    before do
      stub_request(:post, 'https://appstore.example.com/v1/payment_requests/searches').to_return(
        status: 201,
        body: {
          metadata: { total_results: 1 },
          data: [
            {
              claim_id: 'claim-123',
              laa_reference: 'LAA-123',
              request_type: 'original'
            }
          ]
        }.to_json
      )
    end

    it 'returns a CSV attachment' do
      get :index, format: :csv, params: { created_at_from: '2026-05-01', created_at_to: '2026-06-01' }

      expect(response.media_type).to eq('text/csv')
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.body).to include('claim_id')
      expect(response.body).to include('claim-123')
      expect(response.body).to include('laa_reference')
      expect(response.body).to include('LAA-123')
    end

    it 'does not search when no search params are provided' do
      expect(AppStoreClient).not_to receive(:new)

      expect { get :index, format: :csv }.to raise_error(ActionController::UnknownFormat)
    end

    it 'does not return a CSV attachment for HTML requests' do
      get :index, format: :html, params: { created_at_from: '2026-05-01', created_at_to: '2026-06-01' }

      expect(response.media_type).to eq('text/html')
      expect(response.headers['Content-Disposition']).to be_nil
    end
  end

  describe 'GET #show' do
    it 'redirects to csv index with permitted params' do
      get :show, params: { id: 'anything', created_at_from: '2026-05-01', created_at_to: '2026-06-01' }

      expect(response).to be_redirect

      location = URI(response.location)
      expect(location.path).to eq(payments_download_index_path)
      expect(Rack::Utils.parse_nested_query(location.query)).to eq(
        'created_at_from' => '2026-05-01',
        'created_at_to' => '2026-06-01',
        'format' => 'csv'
      )
    end
  end
end
