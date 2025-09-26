require 'rails_helper'

RSpec.describe 'NSM payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint)   { 'https://appstore.example.com/v1/payment_requests/searches' }

  let(:search_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending'
    }
  end

  before do
    stub_search(endpoint, search_params)
    sign_in caseworker
  end

  describe 'claim type' do
    it 'shows the claim type page' do
      start_new_payment_request

      expect(page)
        .to have_title('Claim type')
        .and have_content('Non-Standard Magistrates')
    end

    it 'shows an error when no claim is selected' do
      start_new_payment_request
      click_button 'Save and continue'
      expect(page).to have_content 'Select a payment claim type'
    end
  end

  describe 'claim details' do
    it 'completes claim details and proceeds' do
      start_new_payment_request
      choose_claim_type("Non-Standard Magistrates'")
      fill_claim_details
      expect(page).to have_title('Claimed costs')
    end

    describe 'claimed costs' do
      it 'completes claimed costs and proceeds' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        fill_claim_details
        fill_claimed_costs
        expect(page).to have_title('Allowed costs')
      end
    end

    describe 'allowed costs' do
      it 'completes claimed costs and proceeds' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs
        expect(page).to have_title('Check your answers')
      end
    end
  end
end
