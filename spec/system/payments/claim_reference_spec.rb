require 'rails_helper'

RSpec.describe 'Search', :javascript, :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }

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
    stub_request(:post, endpoint).to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
        data: search_data,
        raw_data: [] }.to_json
    )
  end

  before do
    search_stub
    sign_in caseworker
    visit edit_payments_claim_reference_path
  end

  it 'displays form with autocomplete component' do
    expect(page).to have_content('LAA reference for the original claim')
    expect(page).to have_content(
      'Start typing the LAA reference or the defendant last name ' \
      'and select one of the suggestions that appear'
    )
  end

  it 'displays 2 references when searching autocomplete component' do
    first_entry_text = 'LAA-ABC123 - Defendant BLOGGS'
    fill_in 'LAA reference for the original claim', with: 'bl'
    # need this to ensure the test waits for the entries to load
    expect(page).to have_content(first_entry_text)
    expect(page.all('li.autocomplete__option').count).to eq 2
    expect(page.all('li.autocomplete__option').first.text).to eq first_entry_text
  end
end
