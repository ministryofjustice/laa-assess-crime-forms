require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::AcClaimDetailsCard do
  subject(:card) { described_class.new(session_answers) }

  describe '#change_link_controller_path' do
    context 'when the claim is linked (AC with NSM ref)' do
      let(:session_answers) do
        {
          'request_type' => 'assigned_counsel',
          'linked_nsm_ref' => 'LAA-NSM-123'
        }
      end

      it 'routes change to claim search' do
        expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
      end
    end

    context 'when the claim is an appeal with a linked reference' do
      let(:session_answers) do
        {
          'request_type' => 'assigned_counsel_appeal',
          'laa_reference' => 'LAA-AC-456'
        }
      end

      it 'routes change to claim search' do
        expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
      end
    end

    context 'when the claim is not linked' do
      let(:session_answers) do
        {
          'request_type' => 'assigned_counsel'
        }
      end

      it 'routes change to office code search' do
        expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
      end
    end

    context 'when request_type is not an assigned counsel variant' do
      let(:session_answers) do
        { 'request_type' => 'non_standard_magistrate' }
      end

      it 'treats as not linked and routes change to office code search' do
        expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
      end
    end
  end
end
