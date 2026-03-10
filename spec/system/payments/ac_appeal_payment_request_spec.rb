require 'rails_helper'

RSpec.describe 'Assigned counsel appeal payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:index_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:linked_claim_endpoint) { 'https://appstore.example.com/v1/linked_claim/searches' }
  let(:ac_claim_ref) { 'LAA-kk1HAd' }
  let(:linked_claim_result) do
    [
      {
        id: '1234',
        laa_reference: ac_claim_ref,
        solicitor_office_code: '1A123B',
        solicitor_firm_name: 'Firm & Sons',
        ufn: '120223/001',
        defendant_last_name: 'Trevors',
        request_type: 'assigned_counsel',
        type: 'AssignedCounselClaim'
      }
    ]
  end
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
      claim_type: 'assigned_counsel_appeal',
      sort_by: 'created_at',
      sort_direction: 'descending'
    }
  end
  let(:empty_search_params) do
    {
      page: 1,
      per_page: 20,
      query: 'garbage',
      request_type: 'assigned_counsel',
      claim_type: 'assigned_counsel_appeal',
      sort_by: 'created_at',
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
    stub_search(linked_claim_endpoint, search_params, linked_claim_result)
    stub_get_ac_claim('https://appstore.example.com/v1/payment_request_claims/1234')
    choose_claim_type('Assigned counsel - appeal')
    expect(page).to have_content('Search for the assigned counsel claim')
    expect(page).to have_button('Create a new record')
  end

  context 'Linked assigned counsel claim exists' do
    before do
      fill_in 'Find a claim', with: ac_claim_ref
      click_button 'Search'
      click_button 'Select'
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'allows user to complete payment journey' do
      fill_date_claim_received

      expect(page).to have_title('Allowed costs')
      expect(page).to have_field(id: 'counsel_costs_net', with: '900.0')
      expect(page).to have_field(id: 'counsel_costs_vat', with: '300.0')
      fill_in id: 'counsel_costs_net', with: '100'
      fill_in id: 'counsel_costs_vat', with: '70'
      click_on 'Continue'

      expect(page).to have_title('Check your answers')
      expect(page).to have_content('Allowed costs')
      expect(page).to have_content('Previously allowed')
      expect(page).to have_content('Total allowed')
      click_on 'Submit payment request'

      expect(page).to have_content('Payment request complete')
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'Linked CRM7 submission exists' do
    let(:crm7_submission_id) { SecureRandom.uuid }
    let(:crm7_reference) { 'laa-crm7002' }
    let(:crm7_search_params) { search_params.merge(query: crm7_reference) }
    let(:crm7_linked_claim_result) do
      [
        crm7_submission_search_result(
          submission_id: crm7_submission_id,
          laa_reference: crm7_reference.upcase
        )
      ]
    end

    before do
      stub_search(linked_claim_endpoint, crm7_search_params, crm7_linked_claim_result)
      stub_crm7_submission_claim(
        submission_id: crm7_submission_id,
        laa_reference: crm7_reference.upcase,
        request_type: 'assigned_counsel_appeal',
        nsm_claim: { 'id' => crm7_submission_id, 'laa_reference' => crm7_reference.upcase }
      )
      fill_in 'Find a claim', with: crm7_reference
      click_button 'Search'
      click_button 'Select'
    end

    it 'allows user to complete payment journey from a submission-backed claim' do
      fill_date_claim_received

      expect(page).to have_title('Allowed costs')
      fill_in id: 'counsel_costs_net', with: '100'
      fill_in id: 'counsel_costs_vat', with: '70'
      click_on 'Save and continue'

      expect(page).to have_title('Check your answers')
      expect(page).to have_content(crm7_reference.upcase)
      click_on 'Submit payment request'

      expect(page).to have_content('Payment request complete')
    end
  end

  context 'No linked assigned counsel claim found' do
    before do
      stub_search(linked_claim_endpoint, empty_search_params, [], 0)
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
      click_on 'Continue'

      expect(page).to have_title('Check your answers')
      expect(page).to have_content('Allowed costs')
      click_on 'Submit payment request'
      expect(page).to have_content('Payment request complete')
    end
  end
end
