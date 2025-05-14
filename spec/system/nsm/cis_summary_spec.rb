require 'rails_helper'

RSpec.describe 'Cis Summary', :stub_oauth_token, type: :system do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    stub_app_store_interactions(claim)
    sign_in user
  end

  context 'when viewing the cis_summaries page' do
    before { visit nsm_claim_cis_summaries_path(claim) }

    it 'has the expected summary tables' do
      expect(page).to have_content('Firm details')
      expect(page).to have_content('Defendant details')
      expect(page).to have_content('Claim summary')
      expect(page).to have_content('Hearing details')
      expect(page).to have_content('Assessment')
    end
  end

  context 'when claim has adjustments' do
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data) }

    before do
      claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
      claim.data['work_items'].first['time_spent'] -= 1
      claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
    end

    it 'total claimed is different from total allowed' do
      visit nsm_claim_cis_summaries_path(claim)
      within('.govuk-table__body .govuk-table__row', text: 'Waiting') do
        expect(page).to have_content(
          'Waiting' \
          '£144.42' \
          '£143.52'
        )
      end
    end
  end

  context 'adjusted claim is rejected' do
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data) }

    before do
      claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
      claim.data['work_items'].first['time_spent'] -= 1
      claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
      claim.state = 'rejected'
    end

    it 'shows total allowed as £0.00' do
      visit nsm_claim_cis_summaries_path(claim)
      within('.govuk-table__body .govuk-table__row', text: 'Profit costs') do
        expect(page).to have_content(
          'Profit costs' \
          '£115.34' \
          '£0.00'
        )
      end
    end
  end

  context 'claim has more than one defendant' do
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data) }
    let(:second_defendant) do
      { 'id' => '5678',
        'maat' => 'AB12124',
        'main' => false,
        'position' => 2,
        'first_name' => 'Darcy',
        'last_name' => 'Drinklater' }
    end

    before do
      claim.data['defendants'] << second_defendant
    end

    it 'assessment shows modified' do
      visit nsm_claim_cis_summaries_path(claim)
      expect(page).to have_content('Defendant 2 last name')
      expect(page).to have_content('Defendant 2 first name')
    end
  end
end
