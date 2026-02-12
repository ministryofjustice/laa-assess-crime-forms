module Payments
  module Steps
    class SubmissionAllowedCostsForm < BasePaymentsForm
      include NumericLimits

      attribute :allowed_profit_cost, :gbp

      validates :allowed_profit_cost,
                presence: true,
                numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: NumericLimits::MAX_FLOAT },
                is_a_number: true

      ALLOWED_COSTS = [:allowed_travel_cost,
                       :allowed_disbursement_cost,
                       :allowed_waiting_cost,
                       :allowed_profit_cost].freeze

      def save
        return false unless valid?

        multi_step_form_session[:allowed_profit_cost] = allowed_profit_cost
        multi_step_form_session[:allowed_total] = calculated_total

        true
      end

      def calculated_total
        ALLOWED_COSTS.sum { |key| BigDecimal(multi_step_form_session[key].to_s) }
      end
    end
  end
end
