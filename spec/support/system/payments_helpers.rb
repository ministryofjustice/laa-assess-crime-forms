# rubocop:disable Metrics/MethodLength, Metrics/ModuleLength
module PaymentsHelpers
  def stub_search(endpoint, body_hash)
    stub_request(:post, endpoint)
      .with(body: body_hash)
      .to_return(
        status: 201,
        body: {
          metadata: { total_results: 1 },
          data: [
            id: SecureRandom.uuid,
            request_type: 'non_standard_mag',
            submitted_at: Time.zone.now.to_s,
            payment_request_claim: {
              id: '1234',
              laa_reference: 'LAA-1004',
              client_last_name: 'Dickens'
            }
          ],
          raw_data: []
        }.to_json
      )
  end

  def stub_get_claim(endpoint)
    stub_request(:get, endpoint)
      .to_return(
        status: 200,
        body: claim.to_json
      )
  end

  def claim
    { 'id' => 'dd9fa50c-12cc-4175-a10c-51a014459ef2',
      'type' => 'NsmClaim',
      'laa_reference' => 'LAA-qWRbvm',
      'solicitor_office_code' => '1asdf',
      'solicitor_firm_name' => 'some name',
      'client_last_name' => 'asdf',
      'stage_code' => 'PROG',
      'work_completed_date' => '2025-10-29 00:00:00 UTC',
      'court_name' => 'Usk - C3208F',
      'court_attendances' => 2,
      'no_of_defendants' => 2,
      'client_first_name' => 'asdf',
      'outcome_code' => 'CP19',
      'matter_type' => '13',
      'youth_court' => true,
      'ufn' => '120223/001',
      'submission_id' => nil,
      'created_at' => '2025-10-29 14:01:57 UTC',
      'updated_at' => '2025-10-29 14:01:57 UTC',
      'payment_requests' =>
      [{ 'id' => '0604df63-ba7f-4cca-87b0-9db0b0e2d02f',
        'submitter_id' => 'e061f876-3863-4bfd-9f25-ffefb942c90e',
        'request_type' => 'non_standard_mag',
        'submitted_at' => '2025-10-29 14:01:57 UTC',
        'date_received' => '2025-10-29 00:00:00 UTC',
        'claimed_profit_cost' => '123.0',
        'allowed_profit_cost' => '123.0',
        'claimed_travel_cost' => '123.0',
        'allowed_travel_cost' => '123.0',
        'claimed_waiting_cost' => '123.0',
        'allowed_waiting_cost' => '123.0',
        'claimed_disbursement_cost' => '123.0',
        'allowed_disbursement_cost' => '123.0',
        'claimed_total' => '492.0',
        'allowed_total' => '492.0',
        'created_at' => '2025-10-29 14:01:57 UTC',
        'updated_at' => '2025-10-29 14:01:57 UTC' },
       { 'id' => 'e34f2e9e-4c4b-4b07-acb1-e5c072ab06e2',
         'submitter_id' => 'e061f876-3863-4bfd-9f25-ffefb942c90e',
         'request_type' => 'non_standard_mag_amendment',
         'submitted_at' => '2025-10-29 14:07:19 UTC',
         'date_received' => '2025-10-29 00:00:00 UTC',
         'claimed_profit_cost' => '123.0',
         'allowed_profit_cost' => '123.0',
         'claimed_travel_cost' => '123.0',
         'allowed_travel_cost' => '123.0',
         'claimed_waiting_cost' => '123.0',
         'allowed_waiting_cost' => '100.0',
         'claimed_disbursement_cost' => '123.0',
         'allowed_disbursement_cost' => '123.0',
         'claimed_total' => '492.0',
         'allowed_total' => '469.0',
         'created_at' => '2025-10-29 14:07:19 UTC',
         'updated_at' => '2025-10-29 14:07:19 UTC' }],
      'assigned_counsel_claim' => nil }
  end

  def start_new_payment_request
    visit payments_requests_path
    click_link 'Create payment request'
    expect(page).to have_title('Claim type')
  end

  def choose_claim_type(label_text)
    within_fieldset('Claim type') do
      # Click the *exact* label in this fieldset only
      find('label', text: /\A#{Regexp.escape(label_text)}\z/).click
    end
    click_button 'Save and continue'
  end

  def date_claim_received(date = '2025-09-24')
    fill_in 'Date claim received', with: date
    click_button 'Save and continue'
  end

  def fill_in_laa_ref(laa_ref = 'laa-1004')
    fill_in 'Find a claim', with: laa_ref
    click_button 'Search'
    within('tr', text: laa_ref.upcase) do
      click_button 'Select claim'
    end
  end

  # rubocop:disable Metrics/ParameterLists
  def fill_claim_details(
    received_on: '2025-09-24',
    firm_office_account_number: 'asdf',
    ufn: '120223/001',
    prosecution_type: 'PROM',
    defendant_first_name: 'Fred',
    defendant_last_name: 'Flintstone',
    defendants_count: '2',
    attendances_count: '2',
    hearing_outcome_code: 'CP17 - Extradition',
    matter_type: '5 - Burglary',
    court: 'Ely - C1166A',
    travel_required: 'Yes',
    work_completed_on: '2025-09-24'
  )
    fill_in 'Date claim received', with: received_on
    fill_in 'Firm office account number', with: firm_office_account_number
    fill_in 'Unique file number', with: ufn
    choose prosecution_type, allow_label_click: true
    fill_in 'Defendant first name', with: defendant_first_name
    fill_in 'Defendant last name', with: defendant_last_name
    fill_in 'Number of defendants', with: defendants_count
    fill_in 'Number of attendances', with: attendances_count
    select hearing_outcome_code, from: 'Hearing outcome code'
    select matter_type, from: 'Matter type'
    select court, from: 'Court'
    choose travel_required, allow_label_click: true
    fill_in 'Date work completed', with: work_completed_on

    click_button 'Save and continue'
  end
  # rubocop:enable Metrics/ParameterLists

  def fill_costs(profit_costs: 10,
                 disbursement_costs: 10,
                 travel_costs: 10,
                 waiting_costs: 10)
    fill_in id: 'profit_costs', with: profit_costs
    fill_in id: 'disbursement_costs', with: disbursement_costs
    fill_in id: 'travel_costs', with: travel_costs
    fill_in id: 'waiting_costs', with: waiting_costs

    click_button 'Save and continue'
  end

  [:fill_claimed_costs, :fill_allowed_costs].each do |name|
    alias_method name, :fill_costs
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ModuleLength
RSpec.configuration.include PaymentsHelpers
