require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::AcClaimDetailsCard do
  subject(:card) { described_class.new(session_answers, params) }

  let(:params) { { id: '1234' } }

  describe '#change_link_controller_path' do
    context 'when the claim is linked (AC with NSM ref)' do
      let(:session_answers) do
        {
          'request_type' => 'assigned_counsel',
          'linked_nsm_reference' => 'LAA-NSM-123'
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

  describe '#row_data' do
    let(:session_answers) do
      {
        'request_type' => 'assigned_counsel_amendment',
        'laa_reference' => 'LAA-AC-123',
        'linked_nsm_reference' => 'LAA-NSM-999',
        'date_claim_assessed' => '2024-06-01T12:00:00Z'
      }
    end

    it 'returns both non-standard magistrate and assigned counsel rows' do
      expect(card.row_data).to include(
        hash_including(head_key: 'linked_non_standard_magistrate', text: 'LAA-NSM-999'),
        hash_including(head_key: 'linked_assigned_counsel', text: 'LAA-AC-123')
      )
    end
  end

  describe '#linked_assigned_counsel' do
    context 'when the request type is an assigned counsel variant' do
      let(:session_answers) do
        {
          'request_type' => 'assigned_counsel_appeal'
        }
      end

      it 'falls back to the CRM8 translation when no reference is stored' do
        expect(card.linked_assigned_counsel[:text]).to eq(
          I18n.t('payments.steps.check_your_answers.edit.sections.claim_details.no_linked_crm8')
        )
      end
    end

    context 'when the request type is not assigned counsel' do
      let(:session_answers) { { 'request_type' => 'non_standard_mag_amendment' } }

      it 'returns nil' do
        expect(card.linked_assigned_counsel).to be_nil
      end
    end
  end
end
