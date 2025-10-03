module PaymentsHelpers
  def stub_search(endpoint, body_hash)
    stub_request(:post, endpoint)
      .with(body: body_hash)
      .to_return(
        status: 201,
        body: {
          metadata: { total_results: 0 },
          data: [],
          raw_data: []
        }.to_json
      )
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
    fill_in 'LAA reference for the original claim', with: laa_ref
    click_button 'Save and continue'
  end

  def choose_laa_reference_check(check)
    choose check
    click_button 'Save and continue'
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

RSpec.configuration.include PaymentsHelpers
