require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::LinkedClaimCard do
  subject(:card) { described_class.new(session_answers) }

  describe '#row_data' do
    let(:session_answers) do
      {
        'request_type' => 'assigned_counsel_amendment',
        'laa_reference' => 'LAA-AC-123',
        'linked_nsm_ref' => 'LAA-NSM-999'
      }
    end

    it 'returns both non-standard magistrate and assigned counsel rows' do
      expect(card.row_data).to contain_exactly(
        hash_including(head_key: 'non_standard_magistrate', text: 'LAA-NSM-999'),
        hash_including(head_key: 'assigned_counsel', text: 'LAA-AC-123')
      )
    end
  end

  describe '#assigned_counsel' do
    context 'when the request type is an assigned counsel variant' do
      let(:session_answers) do
        {
          'request_type' => 'assigned_counsel_appeal'
        }
      end

      it 'falls back to the CRM8 translation when no reference is stored' do
        expect(card.assigned_counsel[:text]).to eq(
          I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_crm8')
        )
      end
    end

    context 'when the request type is not assigned counsel' do
      let(:session_answers) { { 'request_type' => 'non_standard_mag_amendment' } }

      it 'returns nil' do
        expect(card.assigned_counsel).to be_nil
      end
    end
  end

  describe '#non_standard_magistrate' do
    context 'when the request is an NSM addition' do
      let(:session_answers) do
        {
          'request_type' => 'non_standard_mag_amendment',
          'linked_laa_reference' => 'LAA-LINKED'
        }
      end

      it 'prefers the linked LAA reference' do
        expect(card.non_standard_magistrate[:text]).to eq('LAA-LINKED')
      end

      it 'falls back to the local LAA reference when no linked reference exists' do
        session_answers.delete('linked_laa_reference')
        session_answers['laa_reference'] = 'LAA-LOCAL'

        expect(card.non_standard_magistrate[:text]).to eq('LAA-LOCAL')
      end
    end

    context 'when the request is an original NSM claim' do
      let(:session_answers) do
        {
          'request_type' => 'non_standard_magistrate',
          'linked_laa_reference' => 'LAA-ORIGINAL'
        }
      end

      it 'uses the linked LAA reference' do
        expect(card.non_standard_magistrate[:text]).to eq('LAA-ORIGINAL')
      end

      it 'falls back to the CRM7 translation when no reference exists' do
        session_answers.delete('linked_laa_reference')

        expect(card.non_standard_magistrate[:text]).to eq(
          I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_crm7')
        )
      end
    end
  end
end
