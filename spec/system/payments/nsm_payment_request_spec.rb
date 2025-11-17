require 'rails_helper'

RSpec.describe 'NSM payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:index_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:search_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending',
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
payment_request: { claimed_total: 100, allowed_total: 10, request_type: 'non_standard_magistrate' } }.to_json
    )
  end

  before do
    create_payment_stub
    stub_search(index_endpoint, search_params)
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

    describe 'submit payment success' do
      it 'submits payment and redirects to payment confirmation' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs
        click_button 'Save and continue'
        expect(page).to have_title('Payment Confirmation')
      end
    end

    describe 'cancel payment request' do
      it 'submits payment and redirects to payment confirmation' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs
        click_link 'Cancel payment request'
        expect(page).to have_title('Payment Requests')
      end
    end
  end
end
