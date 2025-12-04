module Payments
  module Steps
    module Ac
      class AllowedCostsForm < BasePaymentsForm
        attribute :allowed_net_assigned_counsel_cost, :gbp
        attribute :allowed_assigned_counsel_vat, :gbp
        attribute :allowed_total, :gbp

        validates :allowed_net_assigned_counsel_cost, :allowed_assigned_counsel_vat,
                  presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true

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
