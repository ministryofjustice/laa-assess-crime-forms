require 'rails_helper'

RSpec.describe Payments::ViewCostsSummary do
  describe '#row_fields' do
    context 'when claim_type is invalid' do
      let(:payment_request) do
        {
          allowed_fake_cost: 10,
          fake_cost: 10,
        }
      end
      let(:payment_request_details) { instance_double(Payments::PaymentRequestDetails, claim_type: 'garbage', payment_request: payment_request, to_be_paid?: true) }

      it 'returns error' do
        expect { described_class.new(payment_request_details).row_fields }
          .to raise_error 'Invalid payment claim type: garbage'
      end
    end
  end
end
