module Payments
  module Steps
    module Nsm
      class ClaimedCostsForm < BasePaymentsForm
        attribute :claimed_profit_cost, :gbp
        attribute :claimed_disbursement_cost, :gbp
        attribute :claimed_travel_cost, :gbp
        attribute :claimed_waiting_cost, :gbp
        attribute :claimed_total, :gbp

        validates :claimed_profit_cost, :claimed_disbursement_cost,
                  :claimed_travel_cost, :claimed_waiting_cost,
                  presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true

        def save
          return false unless valid?

          attribute_names.grep(/_cost$/).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session['claimed_total'] = calculated_costs

          true
        end
      end
    end
  end
end
