require 'rails_helper'

RSpec.describe Payments::CostsSummary do
  let(:claimed_costs) do
    {
      'claimed_travel_costs' => 50.0,
      'claimed_waiting_costs' => 200.0,
      'claimed_profit_costs' => 1200.30,
      'claimed_disbursement_costs' => 20.0,
      'total_claimed_costs' => 0.00
    }
  end

  let(:allowed_costs) do
    {
      'allowed_travel_costs' => 40.0,
      'allowed_waiting_costs' => 100.0,
      'allowed_profit_costs' => 1100.30,
      'allowed_disbursement_costs' => 10.0,
      'total_allowed_costs' => 10.00
    }
  end

  let(:data) { claimed_costs.merge(allowed_costs) }

  it 'shows totals values from data' do
    formatted_fields = described_class.new(data).formatted_summed_fields
    expect(formatted_fields[:total_claimed]).to eq({ numeric: true, text: '£0.00' })
    expect(formatted_fields[:total_allowed]).to eq({ numeric: true, text: '£10.00' })
  end

  context 'when data comes from app store' do
    let(:claimed_costs) do
      {
        'travel_cost' => 50.0,
        'waiting_cost' => 200.0,
        'profit_cost' => 1200.30,
        'disbursement_cost' => 20.0
      }
    end

    let(:allowed_costs) do
      {
        'allowed_travel_cost' => 40.0,
        'allowed_waiting_cost' => 100.0,
        'allowed_profit_cost' => 1100.30,
        'allowed_disbursement_cost' => 10.0
      }
    end

    it 'correctly calculates totals' do
      formatted_fields = described_class.new(data).formatted_summed_fields
      expect(formatted_fields[:total_claimed]).to eq({ numeric: true, text: '£1,470.30' })
      expect(formatted_fields[:total_allowed]).to eq({ numeric: true, text: '£1,250.30' })
    end
  end

  context 'when there is no allowed cost data' do
    let(:allowed_costs) { nil }

    it 'errors when trying to show data' do
      expect { described_class.new(data).formatted_summed_fields }.to raise_error StandardError
    end
  end
end
