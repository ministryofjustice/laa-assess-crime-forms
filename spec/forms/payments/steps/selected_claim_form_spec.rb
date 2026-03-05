require 'rails_helper'

RSpec.describe Payments::Steps::SelectedClaimForm, type: :model do
  subject(:form) { described_class.new(payment_request_claim_id:, claim_type:) }

  let(:payment_request_claim_id) { 'abc-123' }
  let(:claim_type) { nil }
  let(:multi_step_form_session) { {} }

  before do
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
      let(:transformer_instance) do
        instance_double(Payments::SelectedClaimTransformer, transform: transformed_claim)
      end

      let(:transformed_claim) do
        {
          laa_reference: 'LAA-qWRbvm',
          claimed_profit_cost: 200,
          original_claimed_profit_cost: 200,
          claimed_total: 275
        }
      end

      before do
        allow(Payments::SelectedClaimTransformer).to receive(:new)
          .with(payment_request_claim_id, multi_step_form_session)
          .and_return(transformer_instance)
      end

      it 'persists the transformed claim attributes to the session' do
        expect(form.save).to be(true)
        expect(multi_step_form_session).to include(transformed_claim)
      end
    end

    context 'when the claim type is Crm7SubmissionClaim' do
      let(:claim_type) { 'Crm7SubmissionClaim' }
      let(:submission_transformer) do
        instance_double(Payments::SelectedSubmissionTransformer, transform: transformed_claim)
      end
      let(:transformed_claim) { { submission_id: 'crm7-123' } }

      before do
        allow(Payments::SelectedSubmissionTransformer).to receive(:new)
          .with(payment_request_claim_id, multi_step_form_session)
          .and_return(submission_transformer)
      end

      it 'delegates to the SelectedSubmissionTransformer' do
        expect(form.save).to be(true)
        expect(Payments::SelectedSubmissionTransformer).to have_received(:new)
          .with(payment_request_claim_id, multi_step_form_session)
        expect(multi_step_form_session).to include(:submission_id)
      end
    end

    context 'when the transformer returns nil' do
      let(:transformer_instance) { instance_double(Payments::SelectedClaimTransformer, transform: nil) }

      before do
        allow(Payments::SelectedClaimTransformer).to receive(:new)
          .with(payment_request_claim_id, multi_step_form_session)
          .and_return(transformer_instance)
      end

      it 'raises a StandardError' do
        expect { form.save }.to raise_error(StandardError)
      end
    end
  end
end
