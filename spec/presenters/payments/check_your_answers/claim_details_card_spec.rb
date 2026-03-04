require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::ClaimDetailsCard do
  describe '#read_only?' do
    subject(:card) { described_class.new(session_answers) }

    let(:session_answers) { { 'request_type' => 'non_standard_magistrate', 'linked_laa_reference' => 'LAA-1234' } }

    it 'keeps claim details editable on check your answers' do
      expect(card.read_only?).to be(false)
    end
  end

  describe '#change_link_controller_path' do
    context 'when request type is non_standard_magistrate' do
      subject(:card) { described_class.new(session_answers) }

      let(:session_answers) { { 'request_type' => 'non_standard_magistrate', 'linked_laa_reference' => linked_ref } }
      let(:linked_ref) { nil }

      context 'and there is no linked claim' do
        it 'returns the office code search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
        end
      end

      context 'and there is a linked claim' do
        let(:linked_ref) { 'LAA-1234' }

        it 'returns the claim search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
        end
      end
    end

    context 'when request type is non_standard_mag_supplemental' do
      subject(:card) { described_class.new(session_answers) }

      let(:session_answers) { { 'request_type' => 'non_standard_mag_supplemental', 'laa_reference' => linked_ref } }
      let(:linked_ref) { nil }

      context 'and there is no linked claim' do
        it 'returns the office code search path' do
          expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
        end
      end

      context 'and there is a linked claim' do
        let(:linked_ref) { 'LAA-5678' }

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
