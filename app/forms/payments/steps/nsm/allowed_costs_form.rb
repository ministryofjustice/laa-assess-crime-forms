module Payments
  module Steps
    module Nsm
      class AllowedCostsForm < BasePaymentsForm
        attribute :allowed_profit_cost, :gbp
        attribute :allowed_disbursement_cost, :gbp
        attribute :allowed_travel_cost, :gbp
        attribute :allowed_waiting_cost, :gbp
        attribute :allowed_total, :gbp

        validates :allowed_profit_cost, :allowed_disbursement_cost,
                  :allowed_travel_cost, :allowed_waiting_cost,
                  presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true

        def save
          return false unless valid?

          attribute_names.grep(/_cost$/).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session[:allowed_total] = calculated_costs

          true
        end
      end
    end
  end
end
