require 'rails_helper'

RSpec.describe 'Check your answers with changes', :javascript, :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:search_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }

  let(:search_params) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending'
    }
  end

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    stub_search(search_endpoint, search_params)
    sign_in caseworker
    start_new_payment_request
    choose_claim_type('Non-standard magistrates')
    select_office_code
    fill_claim_details
    fill_claimed_costs
    fill_allowed_costs
    within('.govuk-summary-card', text: 'Claim details') do
      click_link 'Change'
    end
    expect(page).to have_title("Solicitor's firm account number")
  end

  describe 'check your answers back link' do
    it 'can navigate back to the check your answers page with the back link' do
      click_link 'Back'
      expect(page).to have_title('Check your answers')
    end

    it 'can reload the page using the address bar without error' do
      refresh
      expect(page).to have_title("Solicitor's firm account number")
    end
  end
end
