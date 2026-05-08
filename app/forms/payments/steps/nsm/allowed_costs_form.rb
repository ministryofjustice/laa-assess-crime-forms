module Payments
  module Steps
    module Nsm
      class AllowedCostsForm < BasePaymentsForm
        include NumericLimits

        attribute :allowed_profit_cost, :gbp
        attribute :allowed_disbursement_cost, :gbp
        attribute :allowed_travel_cost, :gbp
        attribute :allowed_waiting_cost, :gbp
        attribute :allowed_total, :gbp

        validates :allowed_profit_cost, :allowed_disbursement_cost,
                  :allowed_travel_cost, :allowed_waiting_cost,
                  presence: true,
                  numericality: { less_than_or_equal_to: NumericLimits::MAX_FLOAT },
                  is_a_number: true

        validates :allowed_profit_cost, :allowed_disbursement_cost,
                  :allowed_travel_cost, :allowed_waiting_cost,
                  numericality: { greater_than_or_equal_to: 0 }, if: -> { not_amendment? }

        def save
          return false unless valid?

          attribute_names.grep(/_cost$/).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session[:allowed_total] = calculated_costs

          true
        end

        private

        def not_amendment?
          multi_step_form_session['request_type'] != 'non_standard_mag_amendment'
        end
      end
    end
  end
end
