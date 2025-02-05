require 'rails_helper'

RSpec.describe 'Supporting Evidence', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    stub_app_store_interactions(claim)
    sign_in user
    visit nsm_claim_supporting_evidences_path(claim)
  end

  context 'There is supporting evidence and nothing is sent by post' do
    it 'can view supporting evidence table' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end

    it 'has a link to download the file' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        click_on('Advocacy evidence _ Tom_TC.pdf')
        expect(current_url).to match(/test.s3.us-stubbed-1.amazonaws.com/)
      end
    end

    it 'no send by post info shown' do
      expect(page).to have_no_content('The provider has chosen to post the evidence to:')
    end
  end

  context 'There is supporting evidence and some evidence is sent by post' do
    let(:claim) { build(:claim, data: build(:nsm_data, send_by_post: true)) }

    before do
      allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: true))
      visit nsm_claim_supporting_evidences_path(claim)
    end

    it 'can view supporting evidence table' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end

    it 'has a link to download the file' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        click_on('Advocacy evidence _ Tom_TC.pdf')
        expect(current_url).to match(/test.s3.us-stubbed-1.amazonaws.com/)
      end
    end

    it 'send by post info is shown' do
      expect(page).to have_content('The provider has chosen to post the evidence to:')
    end
  end

  context 'There is supporting evidence sent by post' do
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data, send_by_post: true, supporting_evidences: []) }

    it 'supporting evidence table not shown' do
      expect(page).to have_no_css('.govuk-table__row')
    end

    context 'when postal evidence feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: true))
        visit nsm_claim_supporting_evidences_path(claim)
      end

      it 'send by post info is shown' do
        expect(page).to have_content('The provider has chosen to post the evidence to:')
      end
    end

    context 'when postal evidence feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: false))
        visit nsm_claim_supporting_evidences_path(claim)
      end

      it 'send by post info is not shown' do
        expect(page).to have_no_content('The provider has chosen to post the evidence to:')
      end
    end

    context 'GDPR documents deleted' do
      let(:claim) { build(:claim, data: build(:nsm_data, gdpr_documents_deleted: true)) }

      it 'shows GDPR documents deleted message' do
        expect(page).to have_content I18n.t('shared.gdpr_documents_deleted.message')
      end

      it 'does not show supporting evidence table' do
        expect(page).to have_no_css('.govuk-table__row')
      end

      it 'does not show send by post info' do
        expect(page).to have_no_content('The provider has chosen to post the evidence to:')
      end
    end
  end
end
