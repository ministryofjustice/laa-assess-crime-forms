module Payments
  module Steps
    module Nsm
      class AllowedCostsForm < BasePaymentsForm
        attribute :allowed_profit_costs, :gbp
        attribute :allowed_disbursement_costs, :gbp
        attribute :allowed_travel_costs, :gbp
        attribute :allowed_waiting_costs, :gbp
        attribute :total_allowed_costs, :gbp

        validates :allowed_profit_costs, :allowed_disbursement_costs,
                  :allowed_travel_costs, :allowed_waiting_costs,
                  presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true

        def save
          return false unless valid?

          attribute_names.grep(/_costs$/).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session[:total_allowed_costs] = calculated_costs

          true
        end
      end
    end
  end
end
