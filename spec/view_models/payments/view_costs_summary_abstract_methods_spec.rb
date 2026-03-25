require 'rails_helper'

RSpec.describe Payments::CostsSummary do
  let(:session_answers) do
    {
      'claimed_total' => '100',
      'allowed_total' => '80',
      'original_claimed_total' => '90',
      'original_allowed_total' => '70'
    }
  end

  it 'requires CostsSummary subclasses to implement abstract methods' do
    summary = described_class.new(session_answers)

    expect { summary.table_fields }.to raise_error('implement this action, if needed, in subclasses')
    expect { summary.change_link }.to raise_error('implement this action, if needed, in subclasses')
  end

  it 'requires CostsSummaryAmended subclasses to implement abstract methods' do
    summary = Payments::CostsSummaryAmended.new(session_answers)

    expect { summary.table_fields }.to raise_error('implement this action, if needed, in subclasses')
    expect { summary.change_link }.to raise_error('implement this action, if needed, in subclasses')
  end

  it 'requires CostsSummaryAmendedAndClaimed subclasses to implement abstract methods' do
    summary = Payments::CostsSummaryAmendedAndClaimed.new(session_answers)

    expect { summary.table_fields }.to raise_error('implement this action, if needed, in subclasses')
    expect { summary.change_link }.to raise_error('implement this action, if needed, in subclasses')
  end
end
