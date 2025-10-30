require 'rails_helper'

RSpec.describe Payments::Steps::SelectedClaimForm, type: :model do
  subject(:form) { described_class.new(payment_request_claim_id:) }

  let(:payment_request_claim_id) { 'abc-123' }
  let(:multi_step_form_session) { {} }

  let(:client_double) { instance_double(AppStoreClient) }

  let(:payment_request_claim_response) do
    {
      'id' => 'abc-123',
      'type' => 'NsmClaim',
      'laa_reference' => 'LAA-qWRbvm',
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

  before do
    allow(AppStoreClient).to receive(:new).and_return(client_double)
    allow(client_double).to receive(:get_payment_request_claim)
      .with(payment_request_claim_id)
      .and_return(payment_request_claim_response)

    # stub the BasePaymentsForm session store
    allow(form).to receive(:multi_step_form_session).and_return(multi_step_form_session)
  end

  describe 'validations' do
    it 'is invalid without a payment_request_claim_id' do
      form.payment_request_claim_id = nil
      expect(form.valid?).to be(false)
      expect(form.errors[:payment_request_claim_id]).to include("can't be blank")
    end

    it 'is valid with a payment_request_claim_id' do
      expect(form.valid?).to be(true)
    end
  end

  describe '#save' do
    context 'when invalid' do
      let(:payment_request_claim_id) { nil }

      it 'returns false and does not touch the session' do
        expect(form.save).to be(false)
        expect(multi_step_form_session).to be_empty
      end
    end

    context 'when valid' do
      it 'populates the multi_step_form_session with claim attributes' do
        result = form.save
        expect(result).to be(true)

        expect(multi_step_form_session[:laa_reference]).to eq('LAA-qWRbvm')
        expect(multi_step_form_session[:claimed_profit_cost]).to eq(200)
        expect(multi_step_form_session[:original_claimed_profit_cost]).to eq(200)
        expect(multi_step_form_session[:claimed_total]).to eq(275)
      end
    end

    context 'when claim returns nil' do
      before do
        allow(form).to receive(:claim).and_return(nil)
      end

      it 'raises a StandardError' do
        expect { form.save }.to raise_error(StandardError)
      end
    end
  end

  describe '#latest_payment_request' do
    context 'when there are payment requests' do
      it 'returns the most recently updated request with duplicated original_* keys' do
        result = form.latest_payment_request(payment_request_claim_response)

        expect(result[:claimed_profit_cost]).to eq(200)
        expect(result[:original_claimed_profit_cost]).to eq(200)
        expect(result[:claimed_travel_cost]).to eq(75)
        expect(result[:original_claimed_travel_cost]).to eq(75)
        expect(result[:claimed_total]).to eq(275)
        expect(result[:original_claimed_total]).to eq(275)
      end
    end

    context 'when payment_requests is blank' do
      it 'returns nil' do
        claim_without_requests = payment_request_claim_response.merge('payment_requests' => [])
        result = form.latest_payment_request(claim_without_requests)
        expect(result).to be_nil
      end
    end

    context 'when claim is nil' do
      it 'raises an error due to missing keys' do
        expect { form.latest_payment_request(nil) }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#dup_original_costs_to' do
    it 'adds original_* keys for NSM claim costs' do
      hash = { claimed_total: 100, claimed_travel_cost: 50 }
      allow(form).to receive(:payment_request_claim).and_return({ 'type' => 'NsmClaim' })

      result = form.dup_original_costs_to(hash)

      expect(result[:original_claimed_total]).to eq(100)
      expect(result[:original_claimed_travel_cost]).to eq(50)
    end

    it 'leaves unrelated keys unchanged' do
      hash = { random_key: 999 }
      allow(form).to receive(:payment_request_claim).and_return({ 'type' => 'NsmClaim' })

      result = form.dup_original_costs_to(hash)
      expect(result.keys).to eq([:random_key])
    end
  end
end
