require 'rails_helper'

RSpec.describe Payments::SelectedSubmissionTransformer do
  subject(:transformer) { described_class.new(payment_request_claim_id, multi_step_form_session) }

  let(:payment_request_claim_id) { 'crm7-abc' }
  let(:multi_step_form_session) { {} }
  let(:claim_record) { instance_double(Claim) }
  let(:view_model) { double('PaymentClaimDetails', to_h: view_model_hash) }

  let(:base_view_model_hash) do
    {
      id: 'crm7-abc',
      laa_reference: 'LAA-CRM7',
      claimed_profit_cost: 80,
      claimed_travel_cost: 20,
      claimed_total: 150,
      allowed_total: 120,
      payment_requests: [
        {
          id: 'pr-1',
          updated_at: '2024-01-01T10:00:00Z',
          claimed_total: 150
        }
      ],
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-02T00:00:00Z',
      type: 'Crm7SubmissionClaim',
      nsm_claim: {
        id: 'nsm-123',
        laa_reference: 'LAA-NSM'
      },
      assigned_counsel_claim: { foo: 'bar' }
    }
  end

  let(:view_model_hash) { base_view_model_hash.deep_dup }

  before do
    allow(Claim).to receive(:load_from_app_store).with(payment_request_claim_id).and_return(claim_record)
    allow(BaseViewModel).to receive(:build).with(:payment_claim_details, claim_record).and_return(view_model)
  end

  describe '#transform' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'returns sanitized claim data with duplicated costs and submission id' do
      result = transformer.transform

      expect(result[:id]).to eq('crm7-abc')
      expect(result[:claimed_total]).to eq(150)
      expect(result[:original_claimed_total]).to eq(150)
      expect(result[:claimed_profit_cost]).to eq(80)
      expect(result[:original_claimed_profit_cost]).to eq(80)
      expect(result).not_to have_key(:payment_requests)
      expect(result).not_to have_key(:type)
      expect(result).not_to have_key(:assigned_counsel_claim)
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'loads the claim from the app store and payment claim details view model' do
      transformer.transform

      expect(Claim).to have_received(:load_from_app_store).with(payment_request_claim_id).at_least(:once)
      expect(BaseViewModel).to have_received(:build).with(:payment_claim_details, claim_record).at_least(:once)
    end

    context 'when the request type is assigned_counsel' do
      let(:multi_step_form_session) { { 'request_type' => 'assigned_counsel' } }

      it 'maps the CRM7 identifiers to assigned counsel attributes' do
        result = transformer.transform

        expect(result[:nsm_claim_id]).to eq('crm7-abc')
        expect(result[:linked_nsm_ref]).to eq('LAA-CRM7')
        expect(result[:laa_reference]).to be_nil
      end
    end

    context 'when the request type is assigned_counsel_appeal' do
      let(:multi_step_form_session) { { 'request_type' => 'assigned_counsel_appeal' } }

      it 'uses the linked NSM claim identifiers' do
        result = transformer.transform

        expect(result[:nsm_claim_id]).to eq('nsm-123')
        expect(result[:linked_nsm_ref]).to eq('LAA-NSM')
      end
    end
  end
end
