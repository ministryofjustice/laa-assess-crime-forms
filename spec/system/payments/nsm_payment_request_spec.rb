require 'rails_helper'

RSpec.describe 'NSM payment request', :javascript, :stub_oauth_token do
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
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
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
      click_button 'Continue'
      expect(page).to have_content 'Select a payment claim type'
    end
  end

  describe 'claim details' do
    it 'completes claim details and proceeds' do
      start_new_payment_request
      choose_claim_type("Non-Standard Magistrates'")
      select_office_code
      fill_claim_details
      expect(page).to have_title('Claimed costs')
    end

    it 'shows error when no office code entered' do
      start_new_payment_request
      choose_claim_type("Non-Standard Magistrates'")
      click_button 'Continue'
      expect(page).to have_content('Enter the office code')
    end

    it 'returns to office code selection when office code is not selected' do
      start_new_payment_request
      choose_claim_type("Non-Standard Magistrates'")
      fill_in "What is the solicitor's firm account number?", with: '1A123B'
      click_button 'Continue'
      choose 'No, I need to change the number', allow_label_click: true
      click_button 'Continue'
      expect(page).to have_content("What is the solicitor's firm account number?")
    end

    it 'shows an error when no field is selected on office code confirmation' do
      start_new_payment_request
      choose_claim_type("Non-Standard Magistrates'")
      fill_in "What is the solicitor's firm account number?", with: '1A123B'
      click_button 'Continue'
      click_button 'Continue'
      expect(page).to have_content('Please select an option')
    end

    describe 'claimed costs' do
      it 'completes claimed costs and proceeds' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        select_office_code
        fill_claim_details
        fill_claimed_costs
        expect(page).to have_title('Allowed costs')
      end
    end

    describe 'allowed costs' do
      it 'completes claimed costs and proceeds' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        select_office_code
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs
        expect(page).to have_title('Check your answers')
      end

      it 'returns to check your answers after changing claim details' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        select_office_code
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs

        expect(page).to have_title('Check your answers')

        within('.govuk-summary-card', text: 'Claim details') do
          click_link 'Change'
        end

        expect(page).to have_content("What is the solicitor's firm account number?")

        select_office_code
        fill_claim_details(defendant_last_name: 'Rubble')

        expect(page).to have_title('Check your answers')
        expect(page).to have_content('Rubble')
      end
    end

    describe 'submit payment success' do
      it 'submits payment and redirects to payment confirmation' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        select_office_code
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs
        click_button 'Submit payment request'
        expect(page).to have_content('Payment request complete')
      end
    end

    describe 'cancel payment request' do
      it 'submits payment and redirects to payment confirmation' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        select_office_code
        fill_claim_details
        fill_claimed_costs
        fill_allowed_costs
        click_link 'Cancel payment request'
        expect(page).to have_title('Payment requests')
      end
    end

    describe 'payment request with custom court' do
      it 'completes claim details with custom court and proceeds' do
        start_new_payment_request
        choose_claim_type("Non-Standard Magistrates'")
        select_office_code
        fill_claim_details(court_name: 'Custom court')
        fill_claimed_costs
        fill_allowed_costs
        expect(page).to have_content('Custom court - N/A')
        click_button 'Submit payment request'
        expect(page).to have_content('Payment request complete')
      end
    end
  end

  describe 'payment request when youth court matter is No' do
    it 'shows the correct details in the Claim details card' do
      start_new_payment_request
      choose_claim_type("Non-Standard Magistrates'")
      select_office_code
      fill_claim_details(youth_court: 'No')
      fill_claimed_costs
      fill_allowed_costs
      expect(page).to have_content('Youth court matter No')
    end
  end

  describe 'appeal', :stub_oauth_token do
    it_behaves_like 'NSM payment request flow', 'appeal'
  end

  describe 'amendment', :stub_oauth_token do
    it_behaves_like 'NSM payment request flow', 'amendment'
  end

  describe 'supplemental', :stub_oauth_token do
    let(:linked_claim_endpoint) { 'https://appstore.example.com/v1/linked_claim/searches' }
    let(:empty_search_params) do
      {
        page: 1,
        per_page: 20,
        sort_by: 'created_at',
        sort_direction: 'descending',
        query: 'garbage',
        request_type: 'non_standard_magistrate',
        claim_type: 'non_standard_mag_supplemental'
      }
    end

    it 'goes to NSM claim details when creating a new supplemental record' do
      start_new_payment_request
      stub_search(linked_claim_endpoint, empty_search_params, [], 0)
      choose_claim_type("Non-Standard Magistrates' - supplemental")
      fill_in 'Find a claim', with: 'garbage'
      click_button 'Search'
      expect(page).to have_content('There are no results that match the search criteria')

      click_button 'Create a new record'
      select_office_code
      expect(page).to have_title('Claim details')

      fill_claim_details
      expect(page).to have_title('Claimed costs')
      fill_claimed_costs
      expect(page).to have_title('Allowed costs')
      fill_allowed_costs
      expect(page).to have_title('Check your answers')
    end

    it_behaves_like 'NSM payment request flow', 'supplemental'
  end
end
