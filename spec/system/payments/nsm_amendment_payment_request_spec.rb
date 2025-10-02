require 'rails_helper'

RSpec.describe 'NSM amendment payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint)   { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:claim_type) { "Non-Standard Magistrates' - amendment" }

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
        .and have_content("Non-Standard Magistrates' - amendment")
    end
  end

  describe 'check laa reference' do
    it 'shows the claim type page' do
      start_new_payment_request
      choose_claim_type(claim_type)
      expect(page).to have_title('LAA reference check')
    end
  end

  context 'laa-reference present' do
    describe 'fill in LAA reference' do
      it 'input laa ref' do
        start_new_payment_request
        choose_claim_type(claim_type)
        choose_laa_reference_check('Yes')
        expect(page).to have_title('LAA Reference')
      end
    end

    describe 'Date received' do
      it 'input date received' do
        start_new_payment_request
        choose_claim_type(claim_type)
        choose_laa_reference_check('Yes')
        fill_in_laa_ref
        expect(page).to have_title('Date received')
      end
    end

    describe 'allowed costs' do
      it 'input claimed costs' do
        start_new_payment_request
        choose_claim_type(claim_type)
        choose_laa_reference_check('Yes')
        fill_in_laa_ref
        date_claim_received
        expect(page).to have_title('Allowed costs')
      end
    end

    describe 'check your answers' do
      it 'shows answers' do
        start_new_payment_request
        choose_claim_type(claim_type)
        choose_laa_reference_check('Yes')
        fill_in_laa_ref
        date_claim_received
        fill_allowed_costs
        expect(page).to have_title('Check your answers')
      end
    end
  end

  context 'no laa-reference' do
    describe 'procedes to claim details' do
      it 'completes laa-reference check and proceeds' do
        start_new_payment_request
        choose_claim_type(claim_type)
        choose_laa_reference_check('No')
        expect(page).to have_title('Claim details')
      end
    end

    describe 'claim details' do
      it 'completes claim details and proceeds' do
        start_new_payment_request
        choose_claim_type(claim_type)
        choose_laa_reference_check('No')
        fill_claim_details
        expect(page).to have_title('Allowed costs')
      end

      describe 'allowed costs' do
        it 'completes allowed costs and proceeds' do
          start_new_payment_request
          choose_claim_type(claim_type)
          choose_laa_reference_check('No')
          fill_claim_details
          fill_allowed_costs
          expect(page).to have_title('Check your answers')
        end
      end
    end
  end
end
