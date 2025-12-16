require 'rails_helper'

RSpec.describe 'NSM payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:index_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:nsm_claim_ref) { 'LAA-qWRbvm' }
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
      query: nsm_claim_ref,
      request_type: 'non_standard_magistrate',
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
payment_request: { claimed_total: 100, allowed_total: 10, request_type: 'assigned_counsel' } }.to_json
    )
  end

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    create_payment_stub
    stub_search(index_endpoint, index_params)
    sign_in caseworker
  end

  context 'Linked NSM claim exists' do
    before do
      start_new_payment_request
      stub_search(index_endpoint, search_params)
      stub_get_claim('https://appstore.example.com/v1/payment_request_claims/1234')
      choose_claim_type('Assigned counsel')
      fill_in 'Find a claim', with: nsm_claim_ref
      click_button 'Search'
      click_button 'Select claim'
    end

    it 'allows user to complete payment journey' do
      expect(page).to have_title('Claim Details')
      fill_ac_claim_details

      expect(page).to have_title('Claimed costs')
      fill_in id: 'counsel_costs_net', with: '150.40'
      fill_in id: 'counsel_costs_vat', with: '100'
      click_on 'Save and continue'

      expect(page).to have_title('Allowed costs')
      fill_in id: 'counsel_costs_net', with: '100'
      fill_in id: 'counsel_costs_vat', with: '70'
      click_on 'Save and continue'

      expect(page).to have_title('Check your answers')
      expect(page).to have_content('Claimed and allowed costs')
      click_on 'Submit payment request'

      expect(page).to have_title('Payment Confirmation')
    end
  end

  context 'No linked NSM claim' do
    before do
      start_new_payment_request
      stub_search(index_endpoint, search_params)
      stub_get_claim('https://appstore.example.com/v1/payment_request_claims/1234')
      choose_claim_type('Assigned counsel')
      fill_in 'Find a claim', with: 'garbage'
      click_on 'Create a new record'
      select_office_code

    end
  end
end
