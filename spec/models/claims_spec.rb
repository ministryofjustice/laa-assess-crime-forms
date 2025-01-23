require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { build(:claim, state:, data:) }
  let(:data) { build(:nsm_data) }
  let(:state) { Claim::GRANTED }

  describe '#formatted_allowed_total' do
    context 'granted' do
      let(:state) { Claim::GRANTED }

      context 'increased adjustment' do
        let(:data) { build(:nsm_data, :increase_adjustment) }

        it 'adjusted cost if adjusted more than claimed' do
          expect(claim.formatted_allowed_total > claim.formatted_claimed_total).to be true
        end
      end

      context 'decreased adjustment' do
        let(:data) { build(:nsm_data, :decrease_adjustment) }

        it 'claimed cost if adjusted less than claimed' do
          expect(claim.formatted_allowed_total).to eq claim.formatted_claimed_total
        end
      end
    end

    context 'rejected' do
      let(:state) { Claim::REJECTED }

      it '£0.00 for rejected claims' do
        expect(claim.formatted_allowed_total).to eq '£0.00'
      end
    end

    context 'part_grant' do
      let(:state) { Claim::PART_GRANT }
      let(:data) { build(:nsm_data, :increase_adjustment) }

      it 'returns adjusted total' do
        expect(claim.formatted_allowed_total).to be > claim.formatted_claimed_total
      end
    end
  end

  describe '#gdpr_documents_deleted?' do
    context 'when gdpr_documents_deleted is true' do
      let(:data) { build(:nsm_data, gdpr_documents_deleted: true) }

      it 'returns true' do
        expect(claim.gdpr_documents_deleted?).to be true
      end
    end

    context 'when gdpr_documents_deleted is false' do
      let(:data) { build(:nsm_data, gdpr_documents_deleted: false) }

      it 'returns false' do
        expect(claim.gdpr_documents_deleted?).to be false
      end
    end

    context 'when gdpr_documents_deleted is not present' do
      let(:data) { build(:nsm_data) }

      it 'returns false' do
        expect(claim.gdpr_documents_deleted?).to be false
      end
    end
  end
end
