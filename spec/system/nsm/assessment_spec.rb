require 'rails_helper'

Rails.describe 'Assessment', :stub_oauth_token, type: :system do
  include ActionView::Helpers::TranslationHelper

  let(:fixed_arbitrary_date) { DateTime.new(2024, 7, 4, 12, 3, 12) }
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )

    stub_app_store_interactions(claim)

    sign_in user
    claim.assigned_user_id = user.id
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'when granted' do
    before do
      travel_to fixed_arbitrary_date
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Grant'
      fill_in 'nsm-make-decision-form-grant-comment-field', with: 'Test Data'
      click_link_or_button 'Submit decision'
    end

    it 'shows comment on overview page' do
      visit nsm_claim_claim_details_path(claim)
      expect(page).to have_content 'Test Data'
    end

    it 'shows assessment date on overview page' do
      visit nsm_claim_claim_details_path(claim)
      expect(page).to have_content 'Date assessed: 4 July 2024'
    end

    it 'shows comment on history page' do
      visit nsm_claim_history_path(claim)
      expect(page).to have_content 'Test Data'
    end

    it 'records a paper trail in the access logs' do
      expect(user.access_logs.where(submission_id: claim.id).order(:created_at).pluck(:controller, :action)).to eq(
        [%w[claim_details show], %w[make_decisions edit], %w[make_decisions update]]
      )
    end
  end

  context 'when part-granted' do
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data) }

    before do
      claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
      claim.data['work_items'].first['time_spent'] -= 1
      claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
    end

    it 'sends a part granted notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Part grant'
      fill_in 'nsm-make-decision-form-partial-comment-field', with: 'Test Data'
      click_link_or_button 'Submit decision'
    end
  end

  context 'when rejected' do
    it 'sends a rejected notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Reject'
      fill_in 'nsm-make-decision-form-reject-comment-field', with: 'Test Data'
      click_link_or_button 'Submit decision'
    end
  end

  context 'can save an assessment and come back later' do
    it 'saves the assessment comment redirects to your claims' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Reject'
      fill_in 'nsm-make-decision-form-reject-comment-field', with: 'Test Data'
      click_link_or_button 'Save and come back later'
      expect(page).to have_content('Your claims')
    end

    it 'persists the assessment decision and comment' do
      visit edit_nsm_claim_make_decision_path(claim)
      choose 'Grant'
      fill_in 'nsm-make-decision-form-grant-comment-field', with: 'Granted but decision not made'
      click_link_or_button 'Save and come back later'
      visit edit_nsm_claim_make_decision_path(claim)
      expect(page).to have_content('Granted but decision not made')
    end
  end

  context 'when further information required' do
    before do
      travel_to fixed_arbitrary_date
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      fill_in 'What updates to the claim are needed?', with: 'Test Data'
    end

    it 'lets me save and come back later' do
      click_link_or_button 'Save and come back later'
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      expect(page).to have_field 'What updates to the claim are needed?', with: 'Test Data'
    end

    context 'when I have sent a claim back' do
      before { click_link_or_button 'Submit' }

      it 'sends a notification' do
        expect(claim.assigned_user_id).to be_nil
      end

      it 'shows the date on the details page' do
        visit nsm_claim_claim_details_path(claim)

        expect(page).to have_content 'Date sent back to provider: 4 July 2024'
      end

      it 'shows the FI details' do
        visit nsm_claim_claim_details_path(claim)

        expect(page).to have_content "Sent back to provider on 4 July 2024\nFurther information request:\nTest Data"
      end
    end

    context 'when NSM RFI loops are enabled' do
      before do
        allow(FeatureFlags).to receive(:nsm_rfi_loop).and_return(
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        )
        allow(WorkingDayService).to receive(:call).with(10).and_return(14.days.from_now)
        click_link_or_button 'Submit'
      end

      it 'adds info to the payload' do
        expect(claim.data['further_information']).to eq(
          [
            {
              'documents' => [],
              'requested_at' => fixed_arbitrary_date.to_json.delete('"'),
              'information_requested' => 'Test Data',
              'caseworker_id' => user.id,
            }
          ]
        )

        expect(claim.data['resubmission_deadline']).to eq 14.days.from_now.to_json.delete('"')
      end
    end
  end

  context 'when navigating', :javascript do
    let(:claim) { build(:claim, data:) }
    let(:data) do
      disbursements = Array.new(100) do |i|
        {
          'id' => SecureRandom.uuid,
          'details' => 'Details',
          'pricing' => 1.0,
          'vat_rate' => 0.2,
          'apply_vat' => 'false',
          'other_type' => 'accountants',
          'vat_amount' => 0.0,
          'prior_authority' => 'yes',
          'disbursement_date' => Date.new(2022, 12, 12) + i,
          'disbursement_type' => 'other',
          'total_cost_without_vat' => 100.0
        }
      end
      work_items = Array.new(200) do |i|
        {
          'id' => SecureRandom.uuid,
          'uplift' => 95,
          'pricing' => 24.0,
          'work_type' => 'waiting',
          'fee_earner' => 'aaa',
          'time_spent' => 161,
          'completed_on' => Date.new(2022, 12, 12) + i
        }
      end
      build(:nsm_data, disbursements:, work_items:)
    end

    it 'includes the disbursement ID when navigating back' do
      visit nsm_claim_disbursements_path(claim)

      clicked_id = claim.data['disbursements'][57]['id']
      position = claim.data['disbursements'][57]['position']
      expect(evaluate_script('window.scrollY')).to eq 0

      find("tbody tr[id=\"#{clicked_id}\"] a").click
      expect(page).to have_content(t('nsm.disbursements.edit.heading.main', position:))

      click_on 'Back'

      expect(page).not_to have_content(t('nsm.disbursements.edit.heading.main', position:))
      expect(current_url).to end_with("##{clicked_id}")
      expect(evaluate_script('window.scrollY')).to be > 0
    end

    it 'includes the work item ID when navigating back' do
      visit nsm_claim_work_items_path(claim)

      clicked_id = claim.data['work_items'][53]['id']
      position = claim.data['work_items'][53]['position']
      expect(evaluate_script('window.scrollY')).to eq 0
      find("tbody tr[id=\"#{clicked_id}\"] a", text: 'Waiting').click
      expect(page).to have_content("Adjust work item #{position}")

      click_on 'Back'

      expect(page).not_to have_content('Adjust work item')
      expect(current_url).to end_with("##{clicked_id}")
      expect(evaluate_script('window.scrollY')).to be > 0
    end
  end
end
