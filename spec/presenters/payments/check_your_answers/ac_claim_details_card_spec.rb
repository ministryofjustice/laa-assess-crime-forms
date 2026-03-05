require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::AcClaimDetailsCard do
  describe '#change_link_controller_path' do
    context 'when request type is assigned_counsel' do
      subject(:card) { described_class.new(session_answers) }

      let(:session_answers) { { 'request_type' => 'assigned_counsel', 'linked_nsm_ref' => linked_ref } }
      let(:linked_ref) { nil }

      context 'and there is no linked claim' do
        it 'returns the office code search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
        end
      end

      context 'and there is a linked claim' do
        let(:linked_ref) { 'LAA-9988' }

        it 'returns the claim search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
        end
      end
    end

    context 'when request type is assigned_counsel_appeal' do
      subject(:card) { described_class.new(session_answers) }

      let(:session_answers) { { 'request_type' => 'assigned_counsel_appeal', 'laa_reference' => linked_ref } }
      let(:linked_ref) { nil }

      context 'and there is no linked claim' do
        it 'returns the office code search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
        end
      end

      context 'and there is a linked claim' do
        let(:linked_ref) { 'LAA-4455' }

        it 'returns the claim search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
        end
      end
    end

    context 'when request type is unsupported' do
      subject(:card) { described_class.new(session_answers) }

      let(:session_answers) { { 'request_type' => 'unsupported_request_type' } }

      it 'returns the office code search path' do
        expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
      end
    end
  end
end
