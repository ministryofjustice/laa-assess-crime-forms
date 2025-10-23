require 'rails_helper'

RSpec.describe Payments::ViewCostsSummary do
  describe '#row_fields' do
    context 'when claim_type is invalid' do
      let(:claim_type) { 'garbage' }
      let(:payment_request) do
        {
          'fake_cost' => 10,
          'allowed_fake_cost' => 10
        }
      end

      it 'returns error' do
        expect { described_class.new(payment_request, claim_type).row_fields }
          .to raise_error 'Invalid payment claim type: garbage'
      end
    end
  end
end
