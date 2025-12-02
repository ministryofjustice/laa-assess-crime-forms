# :nocov:
# :nocov:
module Payments
  module Steps
    module Ac
      class AllowedCostsForm < BasePaymentsForm
        attribute :allowed_net_counsel_cost, :gbp
        attribute :allowed_vat_counsel_cost, :gbp
        attribute :allowed_total, :gbp

        validates :allowed_net_counsel_cost, :allowed_vat_counsel_cost,
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
# :nocov:

# :nocov:
