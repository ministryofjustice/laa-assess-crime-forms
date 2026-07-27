require 'rails_helper'

# These specs will not run unless the `INCLUDE_ACCESSIBILITY_SPECS` env var is set
RSpec.describe 'Accessibility', :accessibility, :stub_oauth_token do
  subject { page }

  before do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )
    stub_app_store_interactions(claim)
    stub_app_store_interactions(application)
    driven_by(:headless_chrome)
    sign_in caseworker
  end

  let(:caseworker) { create(:caseworker) }
  let(:application) { build(:prior_authority_application) }
  let(:claim) { build(:claim) }
  let(:be_axe_clean_with_caveats) do
    # Ignoring known false positive around skip links, see: https://design-system.service.gov.uk/components/skip-link/#when-to-use-this-component
    # Ignoring known false positive around aria-expanded attributes on conditional reveal radios, see: https://github.com/alphagov/govuk-frontend/issues/979
    be_axe_clean.excluding('.govuk-skip-link')
                .skipping('aria-allowed-attr')
  end

  context 'when viewing claim-specific screens' do
    %i[nsm_claim_claim_details
       nsm_claim_supporting_evidences
       nsm_claim_history
       edit_nsm_claim_change_risk
       edit_nsm_claim_make_decision
       edit_nsm_claim_send_back
       edit_nsm_claim_unassignment
       edit_nsm_claim_letters_and_calls_uplift
       nsm_claim_letters_and_calls_uplift
       edit_nsm_claim_work_items_uplift
       edit_nsm_claim_work_items_uplift].each do |path|
      describe "#{path} screen" do
        before do
          claim.assigned_user_id = caseworker.id
          visit send(:"#{path}_path", claim)
        end

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end

    describe 'when dealing with letters and calls' do
      %i[nsm_claim_letters_and_calls
         edit_nsm_claim_letters_and_call
         edit_nsm_claim_letters_and_call].each do |path|
        describe "#{path} screen" do
          before { visit send(:"#{path}_path", claim, :letters) }

          it 'is accessible' do
            expect(page).to(be_axe_clean_with_caveats)
          end
        end
      end
    end

    describe 'when dealing with a specific work item' do
      let(:item_id) { claim.data.dig('work_items', 0, 'id') }

      %i[nsm_claim_work_item
         edit_nsm_claim_work_item].each do |path|
        describe "#{path} screen" do
          before { visit send(:"#{path}_path", claim, item_id) }

          it 'is accessible' do
            expect(page).to(be_axe_clean_with_caveats)
          end
        end
      end
    end

    describe 'when dealing with a specific disbursement' do
      let(:item_id) { claim.data.dig('disbursements', 0, 'id') }

      %i[nsm_claim_disbursement
         edit_nsm_claim_disbursement].each do |path|
        describe "#{path} screen" do
          before { visit send(:"#{path}_path", claim, item_id) }

          it 'is accessible' do
            expect(page).to(be_axe_clean_with_caveats)
          end
        end
      end
    end
  end

  context 'when viewing general screens' do
    %i[your_nsm_claims
       open_nsm_claims
       closed_nsm_claims
       about_cookies
       your_prior_authority_applications].each do |path|
      describe "#{path} screen" do
        before { visit send(:"#{path}_path") }

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when viewing application-specific screens' do
    %i[prior_authority_application
       prior_authority_application_adjustments].each do |path|
      describe "#{path} screen" do
        before do
          visit send(:"#{path}_path", application)
        end

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when viewing payments screens' do
    let(:payments_index_endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
    let(:payments_index_params) do
      {
        page: 1,
        per_page: 20,
        sort_by: 'submitted_at',
        sort_direction: 'descending',
      }
    end

    before do
      allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
      stub_search(payments_index_endpoint, payments_index_params)
    end

    it 'has an accessible payments list screen' do
      visit payments_requests_path

      expect(page).to(be_axe_clean_with_caveats)
    end

    it 'has an accessible payments search screen' do
      visit new_payments_search_path

      expect(page).to(be_axe_clean_with_caveats)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'has accessible NSM payment journey screens' do
      start_new_payment_request
      expect(page).to(be_axe_clean_with_caveats)

      choose_claim_type('Non-standard magistrates')
      expect(page).to have_content("What is the solicitor's firm account number?")
      expect(page).to(be_axe_clean_with_caveats)

      fill_in "What is the solicitor's firm account number?", with: '1A123B'
      click_button 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      choose 'Yes', allow_label_click: true
      click_button 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      fill_claim_details
      expect(page).to(be_axe_clean_with_caveats)

      fill_claimed_costs
      expect(page).to(be_axe_clean_with_caveats)

      fill_allowed_costs
      expect(page).to(be_axe_clean_with_caveats)
    end

    it 'has accessible assigned counsel payment journey screens' do
      start_new_payment_request
      choose_claim_type('Assigned counsel')
      expect(page).to(be_axe_clean_with_caveats)

      click_on 'Create a new record'
      expect(page).to(be_axe_clean_with_caveats)

      fill_in "What is the solicitor's firm account number?", with: '1A123B'
      click_button 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      choose 'Yes', allow_label_click: true
      click_button 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      fill_in 'What is the assigned counsel account number?', with: '1A123C'
      click_button 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      choose 'Yes', allow_label_click: true
      click_button 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      fill_ac_claim_details
      expect(page).to(be_axe_clean_with_caveats)

      fill_in id: 'counsel_costs_net', with: '150.40'
      fill_in id: 'counsel_costs_vat', with: '100'
      click_on 'Continue'
      expect(page).to(be_axe_clean_with_caveats)

      fill_in id: 'counsel_costs_net', with: '100'
      fill_in id: 'counsel_costs_vat', with: '70'
      click_on 'Continue'
      expect(page).to(be_axe_clean_with_caveats)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'when signed out' do
    before do
      visit root_path
      click_on 'Sign out'
    end

    describe 'root screen' do
      before { visit '/' }

      it 'is accessible' do
        expect(page).to(be_axe_clean_with_caveats)
      end
    end
  end
end
