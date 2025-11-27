require 'rails_helper'

RSpec.describe 'View payment request', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:id) { SecureRandom.uuid }
  let(:endpoint) { "https://appstore.example.com/v1/payment_request_claim/#{id}" }
  let(:laa_reference) { 'LAA-ODJUfL' }
  let(:submission_id) { nil }
  let(:youth_court) { true }

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    sign_in caseworker
  end

  context 'when payment is for an NsmClaim' do
    let(:related_payments) do
      [
        {
          'id' => SecureRandom.uuid,
          'submitter_id' => caseworker.id,
          'request_type' => 'assigned_counsel',
          'submitted_at' => '2025-09-14 10:31:07 UTC',
          'date_received' => '2025-09-16 10:31:07 UTC',
          'claimed_net_assigned_counsel_cost' => '100',
          'claimed_assigned_counsel_vat' => '20',
          'allowed_net_assigned_counsel_cost' => '90',
          'allowed_assigned_counsel_vat' => '18',
          'created_at' => '2025-10-07 10:31:07 UTC',
          'updated_at' => '2025-10-07 10:31:07 UTC'
        },
        {
          'id' => SecureRandom.uuid,
          'submitter_id' => caseworker.id,
          'request_type' => 'assigned_counsel_amendment',
          'submitted_at' => '2025-10-14 10:31:07 UTC',
          'date_received' => '2025-09-16 10:31:07 UTC',
          'claimed_net_assigned_counsel_cost' => nil,
          'claimed_assigned_counsel_vat' => nil,
          'allowed_net_assigned_counsel_cost' => '100',
          'allowed_assigned_counsel_vat' => '20',
          'created_at' => '2025-10-07 10:31:07 UTC',
          'updated_at' => '2025-10-07 10:31:07 UTC'
        },
      ]
    end
    let(:related_claim) do
      {
        'id' => SecureRandom.uuid,
        'laa_reference' => 'LAA-XYZ321',
        'date_received' => '2025-10-07 10:31:07 UTC',
        'counsel_firm_name' => 'Counsel Firm',
        'counsel_office_code' => '320AB21',
        'client_last_name' => 'Smith',
        'payment_requests' => related_payments
      }
    end

    let(:payment_requests) do
      [
        {
          'id' => id,
          'submitter_id' => caseworker.id,
          'request_type' => 'non_standard_magistrate',
          'submitted_at' => '2025-10-7 10:31:07 UTC',
          'date_received' => '2025-09-07 10:31:07 UTC',
          'claimed_profit_cost' => '300.4',
          'allowed_profit_cost' => '250.4',
          'claimed_travel_cost' => '20.55',
          'allowed_travel_cost' => '0.0',
          'claimed_waiting_cost' => '10.33',
          'allowed_waiting_cost' => '6.4',
          'claimed_disbursement_cost' => '100.0',
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
        'solicitor_office_code' => '1A123B',
        'solicitor_firm_name' => 'The Firm',
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
        'payment_requests' => payment_requests,
        'assigned_counsel_claim' => related_claim
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

    it 'shows related payments tab' do
      click_on 'Related payment requests'
      expect(page).to have_selector '.govuk-heading-l', text: 'Related payment requests'
      expect(all('table td, table th').map(&:text)).to eq(
        [
          'LAA reference', 'Firm name', 'Defendant', 'Payment type', 'Submitted',
          'LAA-XYZ321', '320AB21', 'Smith', 'Assigned counsel', '14 September 2025',
          'LAA-XYZ321', '320AB21', 'Smith', 'Assigned counsel - amendment', '14 October 2025'
        ]
      )
      expect(page).to have_content 'Showing 2 of 2 payment requests'

      click_link 'Submitted'
      expect(all('table td, table th').map(&:text)).to eq(
        [
          'LAA reference', 'Firm name', 'Defendant', 'Payment type', 'Submitted',
          'LAA-XYZ321', '320AB21', 'Smith', 'Assigned counsel - amendment', '14 October 2025',
          'LAA-XYZ321', '320AB21', 'Smith', 'Assigned counsel', '14 September 2025'
        ]
      )
    end

    context 'when there are many related payment requests' do
      before do
        5.times { related_claim['payment_requests'] += related_payments }
      end

      it 'shows multiple pages' do
        click_on 'Related payment requests'
        expect(page).to have_content '1 to 10 of 12 payment requests'
        click_on 'Next'
        expect(page).to have_content '11 to 12 of 12 payment requests'
      end
    end

    context 'when there are multiple payments including an amendment' do
      let(:payment_requests) do
        [
          {
            'id' => 'ed374f60-1a8b-4c2a-9ff4-135e35109c81',
            'submitter_id' => caseworker.id,
            'request_type' => 'non_standard_magistrate',
            'submitted_at' => '2025-09-12 10:31:07 UTC',
            'date_received' => '2025-09-07 10:31:07 UTC',
            'claimed_profit_cost' => '300.4',
            'allowed_profit_cost' => '250.4',
            'claimed_travel_cost' => '20.55',
            'allowed_travel_cost' => '0.0',
            'claimed_waiting_cost' => '10.33',
            'allowed_waiting_cost' => '6.4',
            'claimed_disbursement_cost' => '100.0',
            'allowed_disbursement_cost' => '50.0',
            'created_at' => '2025-10-07 10:31:07 UTC',
            'updated_at' => '2025-10-07 10:31:07 UTC'
          },
          {
            'id' => 'bs374f60-2fa8-332a-12ad-123d35104b11',
            'submitter_id' => caseworker.id,
            'request_type' => 'non_standard_mag_amendment',
            'submitted_at' => '2025-10-12 10:31:07 UTC',
            'date_received' => '2025-09-07 10:31:07 UTC',
            'claimed_profit_cost' => '350.4',
            'allowed_profit_cost' => '200.4',
            'claimed_travel_cost' => '20.55',
            'allowed_travel_cost' => '0.0',
            'claimed_waiting_cost' => '10.33',
            'allowed_waiting_cost' => '6.4',
            'claimed_disbursement_cost' => '100.0',
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
      let(:search_params) do
        { page: 1,
          sort_by: 'submitted_at',
          sort_direction: 'descending',
          submission_id: claim.id,
          per_page: 20 }
      end

      before do
        stub_app_store_interactions(claim)
        stub_request(:post, 'https://appstore.example.com/v1/payment_requests/searches').with(body: search_params).to_return(
          status: 201,
          body: { metadata: { total_results: 0 },
            raw_data: [] }.to_json
        )
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

  context 'when payment is for an AssignedCounselClaim' do
    let(:related_claim) { nil }
    let(:payload) do
      {
        'id' => id,
        'laa_reference' => 'LAA-XYZ321',
        'ufn' => '01112025/001',
        'type' => 'AssignedCounselClaim',
        'date_received' => '2025-10-07 10:31:07 UTC',
        'counsel_firm_name' => 'Counsel Firm',
        'counsel_office_code' => 'XYZB21',
        'solicitor_office_code' => 'AB2034',
        'solicitor_firm_name' => 'Solicitor Firm',
        'client_last_name' => 'Smith',
        'nsm_claim' => related_claim,
        'payment_requests' => [
          {
            'id' => SecureRandom.uuid,
            'submitter_id' => caseworker.id,
            'request_type' => 'assigned_counsel',
            'submitted_at' => '2025-09-14 10:31:07 UTC',
            'date_received' => '2025-09-16 10:31:07 UTC',
            'claimed_net_assigned_counsel_cost' => '100',
            'claimed_assigned_counsel_vat' => '20',
            'allowed_net_assigned_counsel_cost' => '90',
            'allowed_assigned_counsel_vat' => '18',
            'created_at' => '2025-10-07 10:31:07 UTC',
            'updated_at' => '2025-10-07 10:31:07 UTC'
          },
          {
            'id' => SecureRandom.uuid,
            'submitter_id' => caseworker.id,
            'request_type' => 'assigned_counsel_amendment',
            'submitted_at' => '2025-10-14 10:31:07 UTC',
            'date_received' => '2025-09-16 10:31:07 UTC',
            'claimed_net_assigned_counsel_cost' => '100',
            'claimed_assigned_counsel_vat' => '20',
            'allowed_net_assigned_counsel_cost' => '100',
            'allowed_assigned_counsel_vat' => '50',
            'created_at' => '2025-10-07 10:31:07 UTC',
            'updated_at' => '2025-10-07 10:31:07 UTC'
          },
        ]
      }
    end

    before do
      allow_any_instance_of(AppStoreClient).to receive(:get_payment_request_claim)
        .and_return(payload)
      visit "payments/requests/#{id}"
    end

    it 'shows the correct top level details' do
      expect(page).to have_content 'Counsel Firm'
      expect(page).to have_content 'LAA-XYZ321'
      expect(page).to have_content 'Allowed: £150.00'
      expect(page).to have_content 'Claim type: Assigned counsel'
      expect(page).to have_content 'Last updated: 14 October 2025'
    end

    it 'shows payment details' do
      expect(page).to have_content 'Payment request'
      expect(page).to have_content 'Allowed costs after amendment'
      expect(all('table td, table th').map(&:text)).to eq(
        [
          '', 'Total claimed', 'Total allowed',
          'Net counsel fees', '£100.00', '£100.00',
          'VAT on counsel fees', '£20.00', '£50.00',
          'Total', 'Total claimed£120.00', 'Total allowed£150.00'
        ]
      )
      click_on '14 September 2025'
      expect(page).to have_content 'Claimed and allowed costs'
    end

    it 'shows claim details' do
      click_on 'Claim details'
      expect(page).to have_selector '.govuk-heading-l', text: 'Claim details'
      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Claim type', 'Assigned counsel',
          'Linked claim', 'LAA-XYZ321',
          'Solicitor office account number', 'AB2034',
          'Solicitor firm name', 'Solicitor Firm',
          'Unique file number', '01112025/001',
          'Defendant name', 'Smith',
          'Counsel account number', 'XYZB21',
          'Counsel name', 'Counsel Firm'
        ]
      )
    end

    it 'shows related claim payments' do
      click_on 'Related payment requests'
      expect(page).to have_selector '.govuk-heading-l', text: 'Related payment requests'
      expect(page).to have_content 'There are no related payment requests for this claim'
    end

    context 'there is an NsmClaim objected atteched to the AssignedCounselClaim' do
      let(:related_claim) do
        {
          'id' => SecureRandom.uuid,
          'laa_reference' => 'LAA-ABZ321',
          'date_received' => '2025-09-07 10:31:07 UTC',
          'solicitor_office_code' => 'A3211B',
          'solicitor_firm_name' => 'Solicitor Firm 2',
          'client_last_name' => 'Andrews',
          'ufn' => '200323/021',
          'payment_requests' => [
            {
              'id' => SecureRandom.uuid,
              'submitter_id' => caseworker.id,
              'request_type' => 'non_standard_magistrate',
              'submitted_at' => '2025-09-12 10:31:07 UTC',
              'date_received' => '2025-09-07 10:31:07 UTC',
              'claimed_profit_cost' => '300.4',
              'allowed_profit_cost' => '250.4',
              'claimed_travel_cost' => '20.55',
              'allowed_travel_cost' => '0.0',
              'claimed_waiting_cost' => '10.33',
              'allowed_waiting_cost' => '6.4',
              'claimed_disbursement_cost' => '100.0',
              'allowed_disbursement_cost' => '50.0',
              'created_at' => '2025-10-07 10:31:07 UTC',
              'updated_at' => '2025-10-07 10:31:07 UTC'
            },
            {
              'id' => SecureRandom.uuid,
              'submitter_id' => caseworker.id,
              'request_type' => 'non_standard_mag_amendment',
              'submitted_at' => '2025-09-13 10:31:07 UTC',
              'date_received' => '2025-09-07 10:31:07 UTC',
              'claimed_profit_cost' => '300.4',
              'allowed_profit_cost' => '250.4',
              'claimed_travel_cost' => '20.55',
              'allowed_travel_cost' => '0.0',
              'claimed_waiting_cost' => '10.33',
              'allowed_waiting_cost' => '6.4',
              'claimed_disbursement_cost' => '100.0',
              'allowed_disbursement_cost' => '50.0',
              'created_at' => '2025-10-07 10:31:07 UTC',
              'updated_at' => '2025-10-07 10:31:07 UTC'
            }
          ]
        }
      end

      it 'shows claim details from related claim' do
        click_on 'Claim details'
        expect(page).to have_selector '.govuk-heading-l', text: 'Claim details'
        expect(all('table td, table th').map(&:text)).to eq(
          [
            'Claim type', 'Assigned counsel',
            'Linked claim', 'LAA-ABZ321',
            'Solicitor office account number', 'A3211B',
            'Solicitor firm name', 'Solicitor Firm 2',
            'Unique file number', '200323/021',
            'Defendant name', 'Smith',
            'Counsel account number', 'XYZB21',
            'Counsel name', 'Counsel Firm'
          ]
        )
      end

      it 'shows the related claim payments' do
        click_on 'Related payment requests'
        expect(all('table td, table th').map(&:text)).to eq(
          [
            'LAA reference', 'Firm name', 'Defendant', 'Payment type', 'Submitted',
            'LAA-ABZ321', 'A3211B', 'Andrews', "Non-standard magistrates'", '12 September 2025',
            'LAA-ABZ321', 'A3211B', 'Andrews', "Non-standard magistrates' - amendment", '13 September 2025'
          ]
        )
        expect(page).to have_content 'Showing 2 of 2 payment requests'
      end
    end
  end

  context 'when payment claim type is invalid' do
    let(:payload) do
      {
        'id' => id,
        'type' => 'garbage'
      }
    end

    before do
      allow_any_instance_of(AppStoreClient).to receive(:get_payment_request_claim)
        .and_return(payload)
    end

    it 'raises an error trying to go to the payment request' do
      expect { visit "payments/requests/#{id}" }.to raise_error 'Invalid claim type: garbage'
    end
  end
end
