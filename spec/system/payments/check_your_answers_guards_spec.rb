require 'rails_helper'

RSpec.describe 'Payment submission safeguards', type: :system do
  let(:caseworker) { create(:caseworker, first_name: 'Sam', last_name: 'Beta') }
  let(:claim_id) { SecureRandom.uuid }
  let(:token) { SecureRandom.uuid }
  let(:app_store_client) { instance_double(AppStoreClient) }
  let(:confirmation_response) do
    {
      'claim' => { 'laa_reference' => 'LAA-123' },
      'payment_request' => {
        'request_type' => 'non_standard_magistrate',
        'allowed_total' => '100.0'
      }
    }
  end
  let(:empty_pagy) { Pagy.new(count: 0, page: 1, items: Pagy::DEFAULT[:items]) }
  let(:your_claims_model) { instance_double(Nsm::V1::YourClaims, execute: true, results: [], pagy: empty_pagy) }
  let(:payments_search_model) { instance_double(Payments::SearchResults, execute: true, pagy: empty_pagy, results: []) }

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    allow(AppStoreClient).to receive(:new).and_return(app_store_client)
    allow(app_store_client).to receive(:create_payment_request).and_return(confirmation_response)
    allow(Nsm::V1::YourClaims).to receive(:new).and_return(your_claims_model)
    allow(Payments::SearchResults).to receive(:new).and_return(payments_search_model)
    allow(BaseViewModel).to receive(:build).and_call_original
    sign_in caseworker
  end

  it 'redirects the caseworker away from Check your answers after a submission-backed payment is created' do
    stub_submission_claim(claim_id)

    visit edit_payments_steps_check_your_answers_path(claim_id, submission: true)
    expect(page).to have_title('Check your answers')

    click_button 'Save and continue'
    expect(page).to have_title('Payment Confirmation')

    visit edit_payments_steps_check_your_answers_path(claim_id, submission: true)

    expect(page).to have_current_path(your_nsm_claims_path)
    expect(page).to have_content(I18n.t('nsm.claims.your.heading'))
  end

  it 'removes stale payments:* session entries before loading a new submission-backed flow' do
    stale_claim_id = SecureRandom.uuid
    visit payments_requests_path

    rack_session['payments_last_submission'] = { 'id' => stale_claim_id, 'idempotency_token' => token }
    rack_session["payments:#{stale_claim_id}"] = { 'foo' => 'bar' }

    new_claim_id = SecureRandom.uuid
    stub_submission_claim(new_claim_id)

    visit edit_payments_steps_check_your_answers_path(new_claim_id, submission: true)

    expect(rack_session["payments:#{stale_claim_id}"]).to be_nil
    expect(page).to have_title('Check your answers')
  end

  # rubocop:disable Naming/MethodParameterName
  def stub_submission_claim(id)
    claim_double = instance_double(Claim)
    allow(Claim).to receive(:load_from_app_store).with(id).and_return(claim_double)

    answers = submission_answers(id)
    allow(BaseViewModel).to receive(:build)
      .with(:payment_claim_details, claim_double)
      .and_return(instance_double(Nsm::V1::PaymentClaimDetails, to_h: answers))
  end
  # rubocop:enable Naming/MethodParameterName

  # rubocop:disable Metrics/MethodLength, Naming/MethodParameterName
  def submission_answers(id)
    timestamp = Time.zone.now
    {
      'id' => id,
      'request_type' => 'non_standard_magistrate',
      'linked_laa_reference' => 'LAA-123',
      'laa_reference' => 'LAA-123',
      'date_received' => timestamp.to_s,
      'solicitor_office_code' => 'ABC123',
      'ufn' => '120223/001',
      'stage_reached' => 'Stage reached',
      'defendant_first_name' => 'Sam',
      'defendant_last_name' => 'Client',
      'number_of_attendances' => '2',
      'number_of_defendants' => '1',
      'hearing_outcome_code' => 'OUT',
      'matter_type' => '5',
      'court' => 'Central Court',
      'youth_court' => 'No',
      'date_completed' => timestamp.to_s,
      'claimed_profit_cost' => '10',
      'claimed_disbursement_cost' => '5',
      'claimed_travel_cost' => '5',
      'claimed_waiting_cost' => '5',
      'claimed_total' => '25',
      'allowed_profit_cost' => '10',
      'allowed_disbursement_cost' => '5',
      'allowed_travel_cost' => '5',
      'allowed_waiting_cost' => '5',
      'allowed_total' => '25',
      'idempotency_token' => token
    }
  end
  # rubocop:enable Metrics/MethodLength, Naming/MethodParameterName

  def rack_session
    page.driver.request.session
  end
end
