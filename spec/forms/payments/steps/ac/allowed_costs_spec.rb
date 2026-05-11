require 'rails_helper'

RSpec.describe Payments::Steps::Ac::AllowedCostsForm, type: :model do
  subject(:form) do
    described_class.new(
      allowed_net_assigned_counsel_cost:,
      allowed_assigned_counsel_vat:
    )
  end

  let(:session_store) { {} }

  let(:allowed_net_assigned_counsel_cost) { BigDecimal('100.0') }
  let(:allowed_assigned_counsel_vat) { BigDecimal('50.0') }
  let(:request_type) { 'assigned_counsel' }

  describe 'validations' do
    before do
      allow(form).to receive(:request_type).and_return(request_type)
    end

    it 'is valid with all costs present and non-negative' do
      expect(form).to be_valid
    end

    it 'is invalid if costs are negative' do
      form.allowed_net_assigned_counsel_cost = -1
      expect(form).not_to be_valid
      expect(form.errors[:allowed_net_assigned_counsel_cost])
        .to include('Allowed net counsel fees must be equal or greater than 0')
    end

    context 'when request type is assigned_counsel_amendment' do
      let(:request_type) { 'assigned_counsel_amendment' }

      it 'is valid with negative costs' do
        form.allowed_net_assigned_counsel_cost = -1
        expect(form).to be_valid
      end
    end
  end
end
