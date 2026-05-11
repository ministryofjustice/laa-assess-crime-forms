module Payments
  module Steps
    module Ac
      class AllowedCostsForm < BasePaymentsForm
        include NumericLimits

        attribute :allowed_net_assigned_counsel_cost, :gbp
        attribute :allowed_assigned_counsel_vat, :gbp
        attribute :allowed_total, :gbp

        validates :allowed_net_assigned_counsel_cost, :allowed_assigned_counsel_vat,
                  presence: true, numericality: {
                    less_than_or_equal_to: NumericLimits::MAX_FLOAT,
                    greater_than_or_equal_to: -NumericLimits::MAX_FLOAT
                  }, is_a_number: true
        validates :allowed_net_assigned_counsel_cost, :allowed_assigned_counsel_vat,
                  numericality: { greater_than_or_equal_to: 0 }, unless: -> { amendment? }
        def save
          return false unless valid?

          attribute_names.excluding(:allowed_total).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session[:allowed_total] = calculated_costs

          true
        end
      end
    end
  end
end
