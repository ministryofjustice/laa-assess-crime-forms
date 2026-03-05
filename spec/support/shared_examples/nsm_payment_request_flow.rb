require 'rails_helper'

RSpec.shared_examples 'NSM payment request flow' do |type_suffix|
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint)   { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:linked_claim_endpoint) { 'https://appstore.example.com/v1/linked_claim/searches' }
  let(:claim_type) { "Non-Standard Magistrates' - #{type_suffix}" }
  let(:claim_type_code) do
    {
      'appeal' => 'non_standard_mag_appeal',
      'amendment' => 'non_standard_mag_amendment',
      'supplemental' => 'non_standard_mag_supplemental'
    }.fetch(type_suffix, 'non_standard_magistrate')
  end
  let(:get_claim_endpoint) { 'https://appstore.example.com/v1/payment_request_claims/1234' }

  let(:linked_claim_result) do
    [
      {
        id: '1234',
        laa_reference: 'LAA-1004',
        solicitor_office_code: '1A123B',
        solicitor_firm_name: 'Firm & Sons',
        ufn: '120223/001',
        defendant_last_name: 'Dickens',
        request_type: 'non_standard_magistrate',
        type: 'NsmClaim'
      }
    ]
  end

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
      sort_by: 'created_at',
      sort_direction: 'descending',
      query: 'laa-1004',
      request_type: 'non_standard_magistrate',
      claim_type: claim_type_code
    }
  end

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    stub_search(endpoint, search_params)
    stub_search(linked_claim_endpoint, claim_search_params, linked_claim_result)
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
    context 'when the linked claim search returns a CRM7 submission' do
      let(:crm7_submission_id) { SecureRandom.uuid }
      let(:crm7_reference) { 'laa-crm7001' }
      let(:claim_search_params) do
        super().merge(query: crm7_reference)
      end
      let(:linked_claim_result) do
        [crm7_submission_search_result(submission_id: crm7_submission_id, laa_reference: crm7_reference.upcase)]
      end
      let(:crm7_request_type) do
        claim_type_code
      end

      before do
        stub_crm7_submission_claim(
          submission_id: crm7_submission_id,
          laa_reference: crm7_reference.upcase,
          request_type: crm7_request_type
        )
      end

      it 'allows continuing the flow with the submission-backed claim' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in 'Find a claim', with: crm7_reference
        click_button 'Search'
        click_button 'Select'

        fill_date_claim_received
        fill_claimed_costs if type_suffix == 'supplemental'
        fill_allowed_costs

        expect(page).to have_title('Check your answers')
        expect(page).to have_content(crm7_reference.upcase)
      end
    end

    describe 'fill in LAA reference' do
      it 'input laa ref' do
        start_new_payment_request
        choose_claim_type(claim_type)
        expect(page).to have_title('Find a claim')
        expect(page).to have_content('Search for the non-standard magistrates claim')
        expect(page).to have_button('Create a new record')
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
          fill_date_claim_received
          expect(page).to have_title('Claimed costs')
        end
      end
    end

    describe 'allowed costs' do
      it 'input claimed costs' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        fill_date_claim_received
        fill_claimed_costs if type_suffix == 'supplemental'
        expect(page).to have_title('Allowed costs')
      end
    end

    describe 'check your answers' do
      it 'shows answers' do
        start_new_payment_request
        choose_claim_type(claim_type)
        fill_in_laa_ref
        fill_date_claim_received
        fill_claimed_costs if type_suffix == 'supplemental'
        fill_allowed_costs
        expect(page).to have_title('Check your answers')
      end
    end
  end
end
