require 'rails_helper'

RSpec.describe 'NSM amendment payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint)   { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:claim_type) { "Non-Standard Magistrates' - amendment" }
  let(:get_claim_endpoint) { 'https://appstore.example.com/v1/payment_request_claims/1234' }

  let(:search_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending'
    }
  end

  let(:claim_search_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending',
      query: 'laa-1004',
      request_type: 'non_standard_magistrate'
    }
  end

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    stub_search(endpoint, search_params)
    stub_search(endpoint, claim_search_params)
    stub_get_claim(get_claim_endpoint)
    sign_in caseworker
  end

  describe 'claim type' do
    it 'shows the claim type page' do
      start_new_payment_request
      expect(page)
        .to have_title('Claim type')
        .and have_content("Non-Standard Magistrates' - amendment")
    end
  end

  context 'Find a claim' do
    describe 'fill in LAA reference' do
      it 'input laa ref' do
        start_new_payment_request
        choose_claim_type(claim_type)
        expect(page).to have_title('Find a claim')
      end
    end

    describe 'Date received' do
      it 'input date received' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        expect(page).to have_title('Date received')
      end
    end

    describe 'allowed costs' do
      it 'input claimed costs' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        date_claim_received
        expect(page).to have_title('Allowed costs')
      end
    end

    describe 'check your answers' do
      it 'shows answers' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        date_claim_received
        fill_allowed_costs
        expect(page).to have_title('Check your answers')
      end
    end
  end
end
