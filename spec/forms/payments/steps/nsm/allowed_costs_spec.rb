require 'rails_helper'

RSpec.describe Payments::Steps::Nsm::AllowedCostsForm, type: :model do
  subject(:form) do
    described_class.new(
      allowed_profit_cost: profit,
      allowed_disbursement_cost: disbursement,
      allowed_travel_cost: travel,
      allowed_waiting_cost: waiting,
      multi_step_form_session: session_store
    )
  end

  let(:session_store) { {} }

  let(:profit) { BigDecimal('100.0') }
  let(:disbursement) { BigDecimal('50.0') }
  let(:travel)      { BigDecimal('25.0') }
  let(:waiting)     { BigDecimal('10.0') }

  describe 'validations' do
    it 'is valid with all costs present and non-negative' do
      expect(form).to be_valid
    end

    it 'is invalid without allowed_profit_costs' do
      form.allowed_profit_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:allowed_profit_cost]).to include('is not a number')
    end

    it 'is invalid without allowed_disbursement_costs' do
      form.allowed_disbursement_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:allowed_disbursement_cost]).to include('is not a number')
    end

    it 'is invalid without allowed_travel_costs' do
      form.allowed_travel_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:allowed_travel_cost]).to include('is not a number')
    end

    it 'is invalid without allowed_waiting_costs' do
      form.allowed_waiting_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:allowed_waiting_cost]).to include('is not a number')
    end

    it 'is invalid with a negative value' do
      form.allowed_profit_cost = -1
      expect(form).not_to be_valid
      expect(form.errors[:allowed_profit_cost]).to include('Allowed profit costs must be equal or greater than 0')
    end
  end

  describe '#save' do
    context 'with valid attributes' do
      it 'returns true' do
        expect(form.save).to be true
      end

      it 'stores each allowed cost in the session' do
        form.save
        expect(session_store).to include(
          allowed_profit_cost: profit,
          allowed_disbursement_cost: disbursement,
          allowed_travel_cost: travel,
          allowed_waiting_cost: waiting
        )
      end

      it 'stores the total_allowed_costs in the session' do
        form.save
        expect(session_store[:allowed_total]).to eq(profit + disbursement + travel + waiting)
      end
    end

    context 'when the form is invalid' do
      let(:travel) { nil }

      it 'returns false' do
        expect(form.save).to be false
      end

      it 'does not update the session' do
        form.save
        expect(session_store).to be_empty
      end
    end
  end
end
