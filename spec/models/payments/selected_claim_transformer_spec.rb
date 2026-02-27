require 'rails_helper'

RSpec.describe Payments::SelectedClaimTransformer do
  subject(:transformer) { described_class.new(payment_request_claim_id, multi_step_form_session) }

  let(:payment_request_claim_id) { 'abc-123' }
  let(:multi_step_form_session) { {} }
  let(:app_store_client) { instance_double(AppStoreClient) }

  let(:base_claim_response) do
    {
      'id' => 'abc-123',
      'type' => 'NsmClaim',
      'laa_reference' => 'LAA-qWRbvm',
      'nsm_claim' => {
        'id' => 'nsm-456',
        'laa_reference' => 'LAA-linked'
      },
      'payment_requests' => [
        {
          'id' => 'pr-1',
          'updated_at' => '2024-01-01T10:00:00Z',
          'claimed_profit_cost' => 100,
          'claimed_travel_cost' => 50,
          'claimed_total' => 150
        },
        {
          'id' => 'pr-2',
          'updated_at' => '2024-01-02T10:00:00Z',
          'claimed_profit_cost' => 200,
          'claimed_travel_cost' => 75,
          'claimed_total' => 275
        }
      ],
      'created_at' => '2024-01-01T00:00:00Z',
      'updated_at' => '2024-01-02T00:00:00Z'
    }
  end

  let(:claim_response) { base_claim_response.deep_dup }

  before do
    allow(AppStoreClient).to receive(:new).and_return(app_store_client)
    allow(app_store_client).to receive(:get_payment_request_claim)
      .with(payment_request_claim_id)
      .and_return(claim_response)
  end

  describe '#transform' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'returns the formatted claim merged with the latest payment request data' do
      result = transformer.transform

      expect(result[:laa_reference]).to eq('LAA-qWRbvm')
      expect(result[:claimed_profit_cost]).to eq(200)
      expect(result[:original_claimed_profit_cost]).to eq(200)
      expect(result[:claimed_travel_cost]).to eq(75)
      expect(result[:original_claimed_travel_cost]).to eq(75)
      expect(result[:claimed_total]).to eq(275)
      expect(result[:original_claimed_total]).to eq(275)
      expect(result).not_to have_key(:payment_requests)
      expect(result).not_to have_key(:type)
    end
    # rubocop:enable RSpec/MultipleExpectations

    context 'when the request type is assigned counsel amendment' do
      let(:multi_step_form_session) { { 'request_type' => 'assigned_counsel_amendment' } }

      it 'adds the linked NSM identifiers to the claim' do
        result = transformer.transform

        expect(result[:nsm_claim_id]).to eq('nsm-456')
        expect(result[:linked_nsm_ref]).to eq('LAA-linked')
        expect(result).not_to have_key(:nsm_claim)
      end
    end
  end
end
