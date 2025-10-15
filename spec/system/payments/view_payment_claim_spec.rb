require 'rails_helper'

RSpec.describe 'View payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:id) { SecureRandom.uuid }
  let(:endpoint) { "https://appstore.example.com/v1/payment_request_claim/#{id}" }
  let(:laa_reference) { 'LAA-ODJUfL' }
  let(:submission_id) { nil }
  let(:youth_court) { true }

  before do
    sign_in caseworker
  end

  context 'when payment is for an NsmClaim' do
    let(:payment_requests) do
      [
        {
          'id' => id,
          'submitter_id' => caseworker.id,
          'request_type' => 'non_standard_mag',
          'submitted_at' => '2025-09-12 10:31:07 UTC',
          'date_claim_received' => '2025-09-07 10:31:07 UTC',
          'profit_cost' => '300.4',
          'allowed_profit_cost' => '250.4',
          'travel_cost' => '20.55',
          'allowed_travel_cost' => '0.0',
          'waiting_cost' => '10.33',
          'allowed_waiting_cost' => '6.4',
          'disbursement_cost' => '100.0',
          'allowed_disbursement_cost' => '50.0',
          'created_at' => '2025-10-07 10:31:07 UTC',
          'updated_at' => '2025-10-07 10:31:07 UTC'
        }
      ]
    end
    let(:payload) do
      {
        'id' => id,
        'type' => 'NsmClaim',
        'laa_reference' => laa_reference,
        'date_received' => '2025-09-07 10:31:07 UTC',
        'office_code' => '1A123B',
        'firm_name' => 'The Firm',
        'stage_code' => 'PROG',
        'work_completed_date' => '2025-07-07 10:31:07 UTC',
        'court_name' => 'Acton',
        'court_attendances' => 1,
        'no_of_defendants' => 2,
        'client_first_name' => 'Ava',
        'client_last_name' => 'Andrews',
        'outcome_code' => 'CP02',
        'matter_type' => '4',
        'youth_court' => youth_court,
        'ufn' => '123456/101',
        'submission_id' => submission_id,
        'created_at' => '2025-10-07 10:31:07 UTC',
        'updated_at' => '2025-10-07 10:31:07 UTC',
        'payment_requests' => payment_requests
      }
    end

    before do
      allow_any_instance_of(AppStoreClient).to receive(:get_payment_request_claim)
        .and_return(payload)
      visit "payments/requests/#{id}"
    end

    it 'shows the correct top level details' do
      expect(page).to have_content 'The Firm'
      expect(page).to have_content 'LAA-ODJUfL'
      expect(page).to have_content 'Allowed: £306.80'
      expect(page).to have_content "Claim type: Non-standard Magistrates'"
      expect(page).to have_content 'Last updated: 7 October 2025'
    end

    it 'does not have tabs when there is only one payment' do
      expect(page).not_to have_css('.govuk-tabs__list')
    end

    it 'shows payment details' do
      expect(page).to have_content 'Payment request'
      expect(page).to have_content 'Claimed and allowed costs'
      expect(all('table td, table th').map(&:text)).to eq(
        [
          '', 'Total claimed', 'Total allowed',
          'Profit costs', '£300.40', '£250.40',
          'Travel', '£20.55', '£0.00',
          'Waiting', '£10.33', '£6.40',
          'Disbursements', '£100.00', '£50.00',
          'Total', 'Total claimed£431.28', 'Total allowed£306.80'
        ]
      )
    end

    it 'shows claim details tab' do
      click_on 'Claim details'
      expect(page).to have_selector '.govuk-heading-l', text: 'Claim details'
      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Claim type', "Non-standard Magistrates'",
          'Date claim received', '7 September 2025',
          'Firm office account number', '1A123B',
          'Firm name', 'The Firm',
          'Unique file number', '123456/101',
          'Stage reached', 'PROG',
          'Defendant name', 'Ava Andrews',
          'Number of defendants', '2',
          'Number of attendances', '1',
          'Hearing outcome code', 'CP02 - Change of solicitor',
          'Matter type', '4 - Robbery',
          'Court', 'Acton',
          'Youth court matter', 'Yes',
          'Date work was completed', '7 July 2025'
        ]
      )
    end

    context 'when there are multiple payments including an amendment' do
      let(:payment_requests) do
        [
          {
            'id' => 'ed374f60-1a8b-4c2a-9ff4-135e35109c81',
            'submitter_id' => caseworker.id,
            'request_type' => 'non_standard_mag',
            'submitted_at' => '2025-09-12 10:31:07 UTC',
            'date_claim_received' => '2025-09-07 10:31:07 UTC',
            'profit_cost' => '300.4',
            'allowed_profit_cost' => '250.4',
            'travel_cost' => '20.55',
            'allowed_travel_cost' => '0.0',
            'waiting_cost' => '10.33',
            'allowed_waiting_cost' => '6.4',
            'disbursement_cost' => '100.0',
            'allowed_disbursement_cost' => '50.0',
            'created_at' => '2025-10-07 10:31:07 UTC',
            'updated_at' => '2025-10-07 10:31:07 UTC'
          },
          {
            'id' => 'bs374f60-2fa8-332a-12ad-123d35104b11',
            'submitter_id' => caseworker.id,
            'request_type' => 'non_standard_mag_amendment',
            'submitted_at' => '2025-10-12 10:31:07 UTC',
            'date_claim_received' => '2025-09-07 10:31:07 UTC',
            'profit_cost' => '350.4',
            'allowed_profit_cost' => '200.4',
            'travel_cost' => '20.55',
            'allowed_travel_cost' => '0.0',
            'waiting_cost' => '10.33',
            'allowed_waiting_cost' => '6.4',
            'disbursement_cost' => '100.0',
            'allowed_disbursement_cost' => '50.0',
            'created_at' => '2025-10-07 10:31:07 UTC',
            'updated_at' => '2025-10-07 10:31:07 UTC'
          },
        ]
      end

      it 'has the correct label for amendment costs' do
        expect(page).to have_content 'Allowed costs after amendment'
      end

      it 'has a tab for each payment' do
        expect(page).to have_css('.govuk-tabs__list')
        click_on '12 September 2025'

        expect(page).to have_content '£300.40'
      end
    end

    context 'when the NsmClaim is attached to existing CRM7 Submission' do
      let(:claim) { build(:claim, state: 'granted') }
      let(:laa_reference) { claim.data['laa_reference'] }
      let(:submission_id) { claim.id }

      before do
        stub_app_store_interactions(claim)
      end

      it 'shows link for original submission in claim details page' do
        click_on 'Claim details'

        expect(page).to have_content 'Original claim'
        click_on "Link to: #{laa_reference}"

        expect(page).to have_content 'Granted'
        expect(page).to have_content laa_reference
      end
    end

    context 'when the claim for the payment is not for a youth court' do
      let(:youth_court) { false }

      it 'shows No for youth court in claim details' do
        click_on 'Claim details'

        expect(all('table td, table th').map(&:text)).to include(
          'Youth court matter', 'No'
        )
      end
    end
  end
end
