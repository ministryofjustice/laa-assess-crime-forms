require 'rails_helper'

RSpec.describe Payments::SelectedSubmissionTransformer do
  subject(:transformer) { described_class.new(payable_claim_id, multi_step_form_session) }

  let(:payable_claim_id) { SecureRandom.uuid }
  let(:multi_step_form_session) { {} }
  let(:app_store_client) { instance_double(AppStoreClient) }
  let(:claimed_profit_cost) { 100 }
  let(:claimed_travel_cost) { 50 }
  let(:claimed_waiting_cost) { 30 }
  let(:claimed_disbursement_cost) { 20 }
  let(:allowed_profit_cost) { 50 }
  let(:allowed_travel_cost) { 40 }
  let(:allowed_waiting_cost) { 25 }
  let(:allowed_disbursement_cost) { 15 }
  let(:claimed_total) { claimed_profit_cost + claimed_travel_cost + claimed_waiting_cost + claimed_disbursement_cost }
  let(:allowed_total) { allowed_profit_cost + allowed_travel_cost + allowed_waiting_cost + allowed_disbursement_cost }
  let(:app_store_payload) do
    {
      'application_id' => payable_claim_id,
      'application_type' => 'crm7',
      'application_state' => 'submitted',
      'version' => 1,
      'json_schema_version' => 1,
      'application' => build(:nsm_data, laa_reference: 'LAA-CRM7'),
      'created_at' => '2024-01-01T00:00:00Z',
      'updated_at' => '2024-01-02T00:00:00Z',
      'events' => [{ 'event_type' => 'decision', 'created_at' => '2024-01-01T00:00:00Z' }]
    }
  end

  before do
    allow(AppStoreClient).to receive(:new).and_return(app_store_client)
    allow(app_store_client).to receive(:get_submission).with(payable_claim_id).and_return(app_store_payload)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:claimed_profit_cost).and_return(claimed_profit_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:claimed_travel_cost).and_return(claimed_travel_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:claimed_waiting_cost).and_return(claimed_waiting_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails)
      .to receive(:claimed_disbursement_cost).and_return(claimed_disbursement_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:allowed_profit_cost).and_return(allowed_profit_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:allowed_travel_cost).and_return(allowed_travel_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:allowed_waiting_cost).and_return(allowed_waiting_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails)
      .to receive(:allowed_disbursement_cost).and_return(allowed_disbursement_cost)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:claimed_total).and_return(claimed_total)
    allow_any_instance_of(Nsm::V1::PaymentClaimDetails).to receive(:allowed_total).and_return(allowed_total)
  end

  describe '#transform' do
    # rubocop:disable RSpec/MultipleExpectations
    context 'when the request type is non_standard_magistrate' do
      let(:multi_step_form_session) { { 'request_type' => 'non_standard_magistrate' } }

      it 'returns sanitized claim data with duplicated costs and submission id' do
        result = transformer.transform

        expect(result[:submission_id]).to eq(payable_claim_id)
        expect(result[:claimed_total]).to eq(claimed_total)
        expect(result[:original_claimed_total]).to eq(claimed_total)
        expect(result[:claimed_profit_cost]).to eq(claimed_profit_cost)
        expect(result[:original_claimed_profit_cost]).to eq(claimed_profit_cost)
        expect(result[:claimed_travel_cost]).to eq(claimed_travel_cost)
        expect(result[:original_claimed_travel_cost]).to eq(claimed_travel_cost)
        expect(result[:claimed_waiting_cost]).to eq(claimed_waiting_cost)
        expect(result[:original_claimed_waiting_cost]).to eq(claimed_waiting_cost)
        expect(result[:claimed_disbursement_cost]).to eq(claimed_disbursement_cost)
        expect(result[:original_claimed_disbursement_cost]).to eq(claimed_disbursement_cost)
        expect(result).not_to have_key(:id)
        expect(result).not_to have_key(:payment_requests)
        expect(result).not_to have_key(:type)
        expect(result).not_to have_key(:assigned_counsel_claim)
      end

      it 'loads the submission payload from the app store' do
        transformer.transform

        expect(app_store_client).to have_received(:get_submission).with(payable_claim_id)
      end
    end

    context 'when the request type is non_standard_mag_appeal' do
      let(:multi_step_form_session) { { 'request_type' => 'non_standard_mag_appeal' } }

      it 'does not return the claim costs' do
        result = transformer.transform

        expect(result[:submission_id]).to eq(payable_claim_id)
        expect(result[:claimed_total]).to be_nil
        expect(result[:original_claimed_total]).to be_nil
        expect(result[:claimed_profit_cost]).to be_nil
        expect(result[:original_claimed_profit_cost]).to be_nil
        expect(result[:claimed_travel_cost]).to be_nil
        expect(result[:original_claimed_travel_cost]).to be_nil
        expect(result[:claimed_waiting_cost]).to be_nil
        expect(result[:original_claimed_waiting_cost]).to be_nil
        expect(result[:claimed_disbursement_cost]).to be_nil
        expect(result[:original_claimed_disbursement_cost]).to be_nil
      end
    end
    # rubocop:enable RSpec/MultipleExpectations

    context 'when the request type is assigned_counsel' do
      let(:multi_step_form_session) { { 'request_type' => 'assigned_counsel' } }

      it 'maps the CRM7 identifiers to assigned counsel attributes' do
        result = transformer.transform

        expect(result[:nsm_claim_id]).to eq(payable_claim_id)
        expect(result[:linked_laa_reference]).to eq('LAA-CRM7')
        expect(result[:laa_reference]).to be_nil
      end
    end

    context 'when the request type is assigned_counsel_appeal' do
      let(:multi_step_form_session) { { 'request_type' => 'assigned_counsel_appeal' } }

      it 'retains the linked LAA reference from the submission' do
        result = transformer.transform

        expect(result[:submission_id]).to eq(payable_claim_id)
        expect(result[:linked_laa_reference]).to eq('LAA-CRM7')
      end
    end
  end
end
