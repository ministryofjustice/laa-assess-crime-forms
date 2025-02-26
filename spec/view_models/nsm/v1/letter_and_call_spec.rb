require 'rails_helper'

RSpec.describe Nsm::V1::LetterAndCall do
  subject(:letterandcall) { described_class.new(params.merge(type: 'letters', submission: build(:claim))) }

  describe '#provider_requested_amount' do
    let(:params) { { count: 2, count_original: 1, uplift: 5, uplift_original: 10 } }

    it 'calculates the correct provider requested amount' do
      expect(letterandcall.provider_requested_amount).to eq(4.5)
    end

    context 'when originals are not set' do
      let(:params) { { count: 10, uplift: 10 } }

      it 'calulates the initial uplift' do
        expect(letterandcall.provider_requested_amount).to eq(44.99)
      end
    end
  end

  describe '#original_uplift' do
    context 'when uplift_original has a value' do
      let(:params) { { uplift_original: 5, uplift: 10 } }

      it 'returns the uplift amount as a percentage' do
        expect(letterandcall.original_uplift).to eq(5)
      end

      context 'when there is no original value' do
        let(:params) { { uplift: 10 } }

        it 'uses the standard uplift' do
          expect(letterandcall.original_uplift).to eq(10)
        end
      end
    end
  end

  describe '#original_count' do
    context 'when count_original has a value' do
      let(:params) { { count_original: 5, count: 10 } }

      it 'returns the count amount as a percentage' do
        expect(letterandcall.original_count).to eq(5)
      end

      context 'when there is no original value' do
        let(:params) { { count: 10 } }

        it 'uses the standard count' do
          expect(letterandcall.original_count).to eq(10)
        end
      end
    end
  end

  describe '#caseworker_amount' do
    let(:params) { { count: 1, uplift: 5 } }

    it 'calculates the correct caseworker amount' do
      expect(letterandcall.caseworker_amount).to eq(4.29)
    end
  end

  describe '#uplift' do
    let(:params) { { uplift: 5 } }

    it 'returns the uplift value' do
      expect(letterandcall.uplift).to eq(5)
    end
  end

  describe '#count' do
    let(:params) { { count: 5 } }

    it 'returns the count value' do
      expect(letterandcall.count).to eq(5)
    end
  end

  describe '#type_name' do
    let(:params) { { type: 'letters' } }

    it 'returns the downcase translated type' do
      expect(letterandcall.type_name).to eq('letters')
    end
  end

  describe '#form_attributes' do
    let(:params) do
      {
        type: 'letters',
        count: 10,
        uplift: 15,
        adjustment_comment: 'second adjustment'
      }
    end

    it 'extracts data for form initialization' do
      expect(letterandcall.form_attributes).to eq(
        'explanation' => 'second adjustment',
        'count' => 10,
        'type' => 'letters',
        'uplift' => 15,
      )
    end
  end

  describe '#table_fields' do
    let(:params) do
      {
        'type' => 'letters',
        'count' => 12,
        'uplift' => 0,
      }
    end

    it 'returns the fields for the table display' do
      expect(letterandcall.table_fields).to eq(
        [
          'Letters',
          { numeric: true, text: '12' },
          { numeric: true, text: '0%' },
          { numeric: true, text: '£49.08' },
          ''
        ]
      )
    end

    context 'when adjustments exist' do
      let(:params) do
        {
          'type' => 'letters',
          'count' => 12,
          'uplift' => 0,
          'count_original' => 15,
          'uplift_original' => 95,
          'adjustment_comment' => 'something'
        }
      end

      it 'also renders caseworker values' do
        expect(letterandcall.table_fields).to eq(
          [
            'Letters',
            { numeric: true, text: '15' },
            { numeric: true, text: '95%' },
            { numeric: true, text: '£119.63' },
            { numeric: true, text: '£49.08' }
          ]
        )
      end
    end
  end

  describe '#adjusted_table_fields' do
    let(:params) do
      {
        'type' => 'letters',
        'count' => 12,
        'uplift' => 0,
        'count_original' => 15,
        'uplift_original' => 95,
        'adjustment_comment' => 'something'
      }
    end

    it 'also renders caseworker values' do
      expect(letterandcall.adjusted_table_fields).to eq(
        [
          'Letters',
          'something',
          { numeric: true, text: '12' },
          { numeric: true, text: '0%' },
          { numeric: true, text: '£49.08' }
        ]
      )
    end
  end

  describe '#uplift?' do
    context 'when provider supplied uplift is positive' do
      let(:params) { { uplift: 10 } }

      it { expect(letterandcall).to be_uplift }
    end

    context 'when uplift is zero' do
      let(:params) { { uplift: 0 } }

      it { expect(letterandcall).not_to be_uplift }

      context 'but was positive' do
        let(:params) { { uplift: 0, uplift_original: 1 } }

        it { expect(letterandcall).to be_uplift }
      end
    end
  end

  describe '#provider_fields' do
    let(:params) do
      {
        'type' => 'letters',
        'count' => 12,
        'uplift' => 0,
        'uplift_original' => 20,
      }
    end

    it 'calculates the correct provider requested amount' do
      expect(letterandcall.provider_fields).to eq(
        '.number' => '12',
        '.rate' => '£4.09',
        '.uplift_requested' => '20%',
        '.total_claimed' => '£58.90',
      )
    end
  end

  describe '#id' do
    let(:params) do
      { 'type' => 'letters' }
    end

    it { expect(letterandcall.id).to eq 'letters' }
  end

  describe '#reduced?' do
    subject { letterandcall.reduced? }

    context 'with a reduced total cost' do
      let(:params) do
        {
          count_original: 2,
          count: 1,
          uplift: 10,
        }
      end

      it { is_expected.to be true }
    end

    context 'with an increased total cost' do
      let(:params) do
        {
          count: 1,
          uplift: 11,
          uplift_original: 10,
        }
      end

      it { is_expected.to be false }
    end

    context 'with an unchanged total cost' do
      let(:params) do
        {
          count: 1,
          uplift: 10,
        }
      end

      it { is_expected.to be false }
    end
  end

  describe '#increased?' do
    subject { letterandcall.increased? }

    context 'with a reduced total cost' do
      let(:params) do
        {
          count_original: 2,
          count: 1,
          uplift: 10,
        }
      end

      it { is_expected.to be false }
    end

    context 'with an increased total cost' do
      let(:params) do
        {
          count: 1,
          uplift: 11,
          uplift_original: 10,
        }
      end

      it { is_expected.to be true }
    end

    context 'with an unchanged total cost' do
      let(:params) do
        {
          count: 1,
          uplift: 10,
        }
      end

      it { is_expected.to be false }
    end
  end

  describe '#backlink_path' do
    context 'when a change has been made' do
      let(:claim) { build(:claim) }
      let(:params) do
        {
          'type' => 'letters',
          'adjustment_comment' => 'test'
        }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.adjusted_nsm_claim_letters_and_calls_path(claim,
                                                                                                       anchor: letterandcall.id)
        expect(letterandcall.backlink_path(claim)).to eq(expected_path)
      end
    end

    context 'when no change has been made' do
      let(:claim) { build(:claim) }
      let(:params) do
        {
          'type' => 'letters',
        }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.nsm_claim_letters_and_calls_path(claim,
                                                                                              anchor: letterandcall.id)
        expect(letterandcall.backlink_path(claim)).to eq(expected_path)
      end
    end
  end
end
