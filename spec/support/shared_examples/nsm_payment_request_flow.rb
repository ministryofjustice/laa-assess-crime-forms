require 'rails_helper'

RSpec.shared_examples 'NSM payment request flow' do |type_suffix|
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint)   { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:claim_type) { "Non-Standard Magistrates' - #{type_suffix}" }
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
        .and have_content(claim_type)
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

    describe 'fills in wrong reference' do
      it 'input date received' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in 'Find a claim', with: ''
        click_button 'Search'
        expect(page).to have_content("can't be blank")
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

    if type_suffix == 'supplemental'
      describe 'claimed costs' do
        it 'input date claim received' do
          start_new_payment_request
          choose_claim_type(claim_type)
          fill_in_laa_ref
          date_claim_received
          expect(page).to have_title('Claimed costs')
        end
      end
    end

    describe 'allowed costs' do
      it 'input claimed costs' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        date_claim_received
        fill_claimed_costs if type_suffix == 'supplemental'
        expect(page).to have_title('Allowed costs')
      end
    end

    describe 'check your answers' do
      it 'shows answers' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        date_claim_received
        fill_claimed_costs if type_suffix == 'supplemental'
        fill_allowed_costs
        expect(page).to have_title('Check your answers')
      end
    end
  end
end
