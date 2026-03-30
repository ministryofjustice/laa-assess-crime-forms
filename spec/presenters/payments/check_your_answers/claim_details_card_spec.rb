require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::ClaimDetailsCard do
  subject(:card) { described_class.new(session_answers) }

  describe '#change_link_controller_path' do
    context 'when the claim is linked (NSM with linked LAA ref)' do
      let(:session_answers) do
        {
          'request_type' => 'non_standard_magistrate',
          'linked_laa_reference' => 'LAA-123'
        }
      end

      it 'routes change to claim search' do
        expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
      end
    end

    context 'when the claim is an amendment with a linked reference' do
      let(:session_answers) do
        {
          'request_type' => 'non_standard_mag_amendment',
          'laa_reference' => 'LAA-456'
        }
      end

      it 'routes change to claim search' do
        expect(card.change_link_controller_path).to eq('payments/steps/claim_search')
      end
    end

    context 'when the claim is not linked' do
      let(:session_answers) do
        {
          'request_type' => 'non_standard_magistrate'
        }
      end

      it 'routes change to office code search' do
        expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
      end
    end

    context 'when request_type is outside NSM linked groupings' do
      let(:session_answers) do
        { 'request_type' => 'assigned_counsel' }
      end

      it 'treats as not linked and routes change to office code search' do
        expect(card.change_link_controller_path).to eq('payments/steps/office_code_search')
      end
    end
  end

  describe '#read_only?' do
    let(:session_answers) do
      {
        'request_type' => 'non_standard_magistrate',
        'linked_laa_reference' => 'LAA-123'
      }
    end

    it 'keeps claim details editable from check your answers' do
      expect(card.read_only?).to be(false)
    end
  end
end
