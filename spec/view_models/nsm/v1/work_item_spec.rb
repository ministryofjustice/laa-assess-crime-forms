require 'rails_helper'

RSpec.describe Nsm::V1::WorkItem do
  subject(:work_item) { described_class.new(params) }

  describe 'table fields' do
    let(:adjustment_comment) { 'something' }
    let(:params) do
      {
        'work_type' => 'waiting',
        'completed_on' => Date.new(2024, 1, 1),
        'time_spent' => 161,
        'uplift' => 0,
        'uplift_original' => 20,
        'pricing' => 24.0,
        'adjustment_comment' => adjustment_comment
      }
    end

    describe '#reason' do
      it { expect(work_item.reason).to eq('something') }
    end

    describe '#formatted_completed_on' do
      it { expect(work_item.formatted_completed_on).to eq('1 Jan 2024') }
    end

    describe '#formatted_time_spent' do
      it {
        expect(work_item.formatted_time_spent).to eq(
          '2<span class="govuk-visually-hidden"> hours</span>:41<span class="govuk-visually-hidden"> minutes</span>'
        )
      }
    end

    describe '#formatted_uplift' do
      it { expect(work_item.formatted_uplift).to eq('20%') }
    end

    describe '#formatted_requested_amount' do
      it { expect(work_item.formatted_requested_amount).to eq('£77.28') }
    end

    describe '#formatted_allowed_time_spent' do
      it {
        expect(work_item.formatted_allowed_time_spent).to eq(
          '2<span class="govuk-visually-hidden"> hours</span>:41<span class="govuk-visually-hidden"> minutes</span>'
        )
      }
    end

    describe '#formatted_allowed_uplift' do
      it { expect(work_item.formatted_allowed_uplift).to eq('0%') }
    end

    describe '#formatted_allowed_amount' do
      it { expect(work_item.formatted_allowed_amount).to eq('£64.40') }

      context 'when no adjustments' do
        let(:adjustment_comment) { nil }

        it { expect(work_item.formatted_allowed_amount).to eq('') }
      end
    end
  end

  describe '#original_time_spent' do
    let(:params) do
      {
        'time_spent' => 100,
        'time_spent_original' => 171,
      }
    end

    it 'shows the correct provider requested time spent' do
      expect(work_item.original_time_spent).to eq(171)
    end
  end

  describe '#original_uplift' do
    let(:params) do
      {
        'uplift' => 0,
        'uplift_original' => 20,
      }
    end

    it 'shows the correct provider requested uplift' do
      expect(work_item.original_uplift).to eq(20)
    end
  end

  describe 'provider_requested_amount' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 10,
        'pricing' => 24.0
      }
    end

    it 'calculates the correct provider requested amount' do
      expect(work_item.provider_requested_amount).to eq(75.24)
    end

    context 'when numbers might lead to floating point rounding errors' do
      let(:params) do
        {
          'time_spent' => 36,
          'uplift' => 0,
          'pricing' => 45.35
        }
      end

      it 'calculates the correct provider requested amount' do
        expect(work_item.provider_requested_amount).to eq(27.21)
      end
    end
  end

  describe '#caseworker_amount' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 0,
        'pricing' => 24.0,
      }
    end

    it 'calculates the correct caseworker requested amount' do
      expect(work_item.caseworker_amount).to eq(68.4)
    end
  end

  describe '#uplift?' do
    context 'when provider supplied uplift is positive' do
      let(:params) { { uplift: 10 } }

      it { expect(work_item).to be_uplift }
    end

    context 'when uplift is zero' do
      let(:params) { { uplift: 0 } }

      it { expect(work_item).not_to be_uplift }

      context 'but has adjustments' do
        let(:params) { { uplift: 0, uplift_original: 10 } }

        it { expect(work_item).to be_uplift }
      end
    end
  end

  describe '#reduced?' do
    subject { work_item.reduced? }

    context 'with a reduced total cost' do
      let(:params) do
        {
          'time_spent_original' => 171,
          'time_spent' => 170,
          'uplift' => 0,
          'pricing' => 24.0,
        }
      end

      it { is_expected.to be true }
    end

    context 'with an increased total cost' do
      let(:params) do
        {
          'time_spent' => 170,
          'uplift' => 0,
          'pricing' => 25.0,
          'pricing_original' => 24.0,
        }
      end

      it { is_expected.to be false }
    end

    context 'with an unchanged total cost' do
      let(:params) do
        {
          'time_spent' => 170,
          'uplift' => 0,
          'pricing' => 25.0,
        }
      end

      it { is_expected.to be false }
    end
  end

  describe '#increased?' do
    subject { work_item.increased? }

    context 'with a reduced total cost' do
      let(:params) do
        {
          'time_spent_original' => 171,
          'time_spent' => 170,
          'uplift' => 0,
          'pricing' => 24.0,
        }
      end

      it { is_expected.to be false }
    end

    context 'with an increased total cost' do
      let(:params) do
        {
          'time_spent' => 170,
          'uplift' => 0,
          'pricing' => 25.0,
          'pricing_original' => 24.0,
        }
      end

      it { is_expected.to be true }
    end

    context 'with an unchanged total cost' do
      let(:params) do
        {
          'time_spent' => 170,
          'uplift' => 0,
          'pricing' => 25.0,
        }
      end

      it { is_expected.to be false }
    end
  end

  describe '#form_attributes' do
    let(:params) do
      {
        'work_type' => 'waiting',
        'time_spent' => 161,
        'uplift' => 0,
        'pricing' => 24.0,
      }
    end

    it 'extracts data for form initialization' do
      expect(work_item.form_attributes).to eq(
        'explanation' => nil,
        'time_spent' => 161,
        'uplift' => 0,
        'work_type_value' => 'waiting',
      )
    end

    context 'when adjustments exists' do
      let(:params) do
        {
          'work_type' => 'waiting',
          'time_spent' => 161,
          'uplift' => 0,
          'pricing' => 24.0,
          'adjustment_comment' => 'second adjustment',
        }
      end

      it 'includes the previous adjustment comment' do
        expect(work_item.form_attributes).to eq(
          'explanation' => 'second adjustment',
          'time_spent' => 161,
          'uplift' => 0,
          'work_type_value' => 'waiting',
        )
      end
    end
  end

  describe '#provider_fields' do
    let(:params) do
      {
        'completed_on' => Time.zone.local(2022, 12, 14, 13, 0o2).to_s,
        'time_spent' => 171,
        'uplift' => 0,
        'uplift_original' => 20,
        'pricing' => 24.0,
        'fee_earner' => 'JGB',
        'work_type' => 'waiting',
      }
    end

    it 'calculates the correct provider requested amount' do
      expect(work_item.provider_fields).to eq(
        '.work_type' => 'Waiting',
        '.date' => '14 December 2022',
        '.time_spent' => '2 hours 51 minutes',
        '.item_rate' => '£24.00',
        '.fee_earner' => 'JGB',
        '.uplift_claimed' => '20%',
        '.total_claimed' => '£82.08',
      )
    end
  end

  describe 'backlink_path' do
    context 'when a change has been made' do
      let(:claim) { create(:claim) }
      let(:params) do
        { 'adjustment_comment' => 'test' }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.adjusted_nsm_claim_work_items_path(claim,
                                                                                                anchor: work_item.id)
        expect(work_item.backlink_path(claim)).to eq(expected_path)
      end
    end

    context 'when no change has been made' do
      let(:claim) { create(:claim) }
      let(:params) do
        {}
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.nsm_claim_work_items_path(claim,
                                                                                       anchor: work_item.id)
        expect(work_item.backlink_path(claim)).to eq(expected_path)
      end
    end
  end
end
