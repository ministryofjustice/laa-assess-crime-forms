require 'rails_helper'

RSpec.describe 'Assigned counsel appeal payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:index_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:ac_claim_ref) { 'LAA-kk1HAd' }
  let(:index_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending'
    }
  end
  let(:search_params) do
    {
      page: 1,
      per_page: 20,
      query: ac_claim_ref,
      request_type: 'assigned_counsel',
      sort_by: 'submitted_at',
      sort_direction: 'descending'
    }
  end
  let(:empty_search_params) do
    {
      page: 1,
      per_page: 20,
      query: 'garbage',
      request_type: 'assigned_counsel',
      sort_by: 'submitted_at',
      sort_direction: 'descending'
    }
  end

  let(:create_endpoint) { 'https://appstore.example.com/v1/payment_requests' }
  let(:create_payload) do
    {
      laa_reference: '123-abc'
    }
  end

  let(:create_payment_stub) do
    stub_request(:post, create_endpoint).to_return(
      status: 201,
      body: { claim: { laa_reference: '1234-abc' },
payment_request: { claimed_total: 100, allowed_total: 10, request_type: 'assigned_counsel_appeal' } }.to_json
    )
  end

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    create_payment_stub
    stub_search(index_endpoint, index_params)
    sign_in caseworker
    start_new_payment_request
    stub_search(index_endpoint, search_params)
    stub_get_ac_claim('https://appstore.example.com/v1/payment_request_claims/1234')
    choose_claim_type('Assigned counsel - appeal')
  end

  context 'Linked assigned counsel claim exists' do
    before do
      fill_in 'Find a claim', with: ac_claim_ref
      click_button 'Search'
      click_button 'Select claim'
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'allows user to complete payment journey' do
      fill_date_claim_received

      expect(page).to have_title('Allowed costs')
      expect(page).to have_field(id: 'counsel_costs_net', with: '900.0')
      expect(page).to have_field(id: 'counsel_costs_vat', with: '300.0')
      fill_in id: 'counsel_costs_net', with: '100'
      fill_in id: 'counsel_costs_vat', with: '70'
      click_on 'Save and continue'

      expect(page).to have_title('Check your answers')
      expect(page).to have_content('Claimed and allowed costs')
      expect(page).to have_content('Previously claimed')
      expect(page).to have_content('Previously allowed')
      click_on 'Submit payment request'

      expect(page).to have_title('Payment Confirmation')
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'No linked assigned counsel claim found' do
    before do
      stub_search(index_endpoint, empty_search_params, [], 0)
      fill_in 'Find a claim', with: 'garbage'
      click_button 'Search'
    end

    it 'Shows no results found message' do
      expect(page).to have_content('There are no results that match the search criteria')
    end

    it 'allows user to complete payment journey' do
      click_button 'Create a new record'
      select_office_code
      fill_ac_claim_details

      expect(page).to have_content('Allowed costs')
      fill_in id: 'counsel_costs_net', with: '100'
      fill_in id: 'counsel_costs_vat', with: '70'
      click_on 'Save and continue'

      expect(page).to have_title('Check your answers')
      expect(page).to have_content('Amended allowed costs')
      click_on 'Submit payment request'
      expect(page).to have_title('Payment Confirmation')
    end
  end
end
