module Payments
  module Steps
    module Nsm
      class ClaimedCostsForm < BasePaymentsForm
        attribute :claimed_profit_costs, :gbp
        attribute :claimed_disbursement_costs, :gbp
        attribute :claimed_travel_costs, :gbp
        attribute :claimed_waiting_costs, :gbp
        attribute :total_claimed_costs, :gbp

        validates :claimed_profit_costs, :claimed_disbursement_costs,
                  :claimed_travel_costs, :claimed_waiting_costs,
                  presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true

        def save
          return false unless valid?

          attribute_names.grep(/_costs$/).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session[:total_claimed_costs] = calculated_costs

          true
        end
      end
    end
  end
end
