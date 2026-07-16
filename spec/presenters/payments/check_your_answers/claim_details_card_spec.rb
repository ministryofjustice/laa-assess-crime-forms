require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::ClaimDetailsCard do
  subject(:card) { described_class.new(session_answers, params) }

  let(:params) { nil }

  describe '#linked_non_standard_magistrate' do
    context 'when the request is an NSM addition' do
      let(:session_answers) do
        {
          'request_type' => 'non_standard_mag_amendment',
          'linked_laa_reference' => 'LAA-LINKED'
        }
      end

      it 'prefers the linked LAA reference' do
        expect(card.linked_non_standard_magistrate[:text]).to eq('LAA-LINKED')
      end

      it 'falls back to the local LAA reference when no linked reference exists' do
        session_answers.delete('linked_laa_reference')
        session_answers['laa_reference'] = 'LAA-LOCAL'

        expect(card.linked_non_standard_magistrate[:text]).to eq('LAA-LOCAL')
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
        expect(card.linked_non_standard_magistrate[:text]).to eq('LAA-ORIGINAL')
      end

      it 'falls back to the CRM7 translation when no reference exists' do
        session_answers.delete('linked_laa_reference')

        expect(card.linked_non_standard_magistrate[:text]).to eq(
          I18n.t('payments.steps.check_your_answers.edit.sections.claim_details.no_linked_crm7')
        )
      end
    end
  end
end
