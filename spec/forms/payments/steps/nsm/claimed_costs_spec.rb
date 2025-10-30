require 'rails_helper'

RSpec.describe Payments::Steps::Nsm::ClaimedCostsForm, type: :model do
  subject(:form) do
    described_class.new(
      claimed_profit_cost: profit,
      claimed_disbursement_cost: disbursement,
      claimed_travel_cost: travel,
      claimed_waiting_cost: waiting,
      multi_step_form_session: session_store
    )
  end

  let(:session_store) { {} }

  let(:profit) { BigDecimal('200.0') }
  let(:disbursement) { BigDecimal('75.0') }
  let(:travel)      { BigDecimal('40.0') }
  let(:waiting)     { BigDecimal('20.0') }

  describe 'validations' do
    it 'is valid with all costs present and non-negative' do
      expect(form).to be_valid
    end

    it 'is invalid without claimed_profit_costs' do
      form.claimed_profit_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:claimed_profit_cost]).to include('is not a number')
    end

    it 'is invalid without claimed_disbursement_costs' do
      form.claimed_disbursement_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:claimed_disbursement_cost]).to include('is not a number')
    end

    it 'is invalid without claimed_travel_costs' do
      form.claimed_travel_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:claimed_travel_cost]).to include('is not a number')
    end

    it 'is invalid without claimed_waiting_costs' do
      form.claimed_waiting_cost = nil
      expect(form).not_to be_valid
      expect(form.errors[:claimed_waiting_cost]).to include('is not a number')
    end

    it 'is invalid with a negative value' do
      form.claimed_profit_cost = -1
      expect(form).not_to be_valid
      expect(form.errors[:claimed_profit_cost]).to include('Claimed profit costs must be equal or greater than 0')
    end
  end

  describe '#save' do
    context 'with valid attributes' do
      it 'returns true' do
        expect(form.save).to be true
      end

      it 'stores each claimed cost in the session' do
        form.save
        expect(session_store).to include(
          claimed_profit_cost: profit,
          claimed_disbursement_cost: disbursement,
          claimed_travel_cost: travel,
          claimed_waiting_cost: waiting
        )
      end

      it 'stores the total_claimed_costs in the session' do
        form.save
        expect(session_store[:claimed_total]).to eq(profit + disbursement + travel + waiting)
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
