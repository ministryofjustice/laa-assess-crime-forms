require 'rails_helper'

RSpec.describe 'Search', :javascript, :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:query) { "Bloggs" }

  let(:search_data) do
    [
      {
        'payment_request_claim' => {
          'laa_reference' => 'LAA-ABC123',
          'client_last_name' => 'Bloggs'
        }
      },
      {
        'payment_request_claim' => {
          'laa_reference' => 'LAA-XYZ123',
          'client_last_name' => 'Bloggs'
        }
      },
    ]
  end

  let(:search_stub) do
    stub_request(:post, endpoint).with(body: payload).to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
        data: search_data,
        raw_data: [] }.to_json
    )
  end

  let(:payload) do
    {
      sort_direction: 'descending',
      query: query
    }
  end

  before do
    search_stub
    sign_in caseworker
    visit edit_payments_claim_reference_path
  end

  it 'displays form with autocomplete component' do
    expect(page).to have_content('LAA reference for the original claim')
    expect(page).to have_content('Start typing the LAA reference or the defendant last name and select one of the suggestions that appear')
  end
end
