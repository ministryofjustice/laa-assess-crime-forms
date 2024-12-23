require 'rails_helper'

RSpec.describe 'Risk', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  let(:search_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 1 },
              raw_data: [claim_data].compact }.to_json
    )
  end

  let(:claim_data) do
    { application_id: claim.id,
      assigned_user_id: user.id,
      last_updated_at: 1.day.ago,
      application_type: 'crm7',
      application_state: claim.state,
      application: { defendant: {}, firm_office: {}, laa_reference: 'LAA-REFERENCE' } }
  end

  before do
    stub_app_store_interactions(claim)
    search_stub
    sign_in user
    claim.assigned_user_id = user.id
    visit open_nsm_claims_path
    click_on 'LAA-REFERENCE'
    expect(page).to have_content 'Low risk'
    click_on 'Change risk'
  end

  it 'lets me change the risk' do
    choose 'Medium risk'
    fill_in 'Explain your decision', with: 'Looks shifty to me'
    click_on 'Change risk'
    expect(page).to have_content 'You changed the claim risk to medium'
  end

  it 'prevents me changing the risk without a reason' do
    choose 'Medium risk'
    click_on 'Change risk'
    expect(page).to have_content "There is a problem on this page\nExplain why you are changing the risk"
  end

  it 'lets me cancel' do
    click_on 'Cancel'
    expect(page).to have_current_path nsm_claim_claim_details_path(claim)
    expect(page).to have_content 'Low risk'
  end

  context 'when app store errors out' do
    before do
      stub_request(:patch, "https://appstore.example.com/v1/submissions/#{claim.id}/metadata").to_return(status: 500)
    end

    it 'errors out' do
      choose 'Medium risk'
      fill_in 'Explain your decision', with: 'Looks shifty to me'
      click_on 'Change risk'
      expect(page).to have_content 'There was a problem saving the change. Please try again.'
    end
  end
end
