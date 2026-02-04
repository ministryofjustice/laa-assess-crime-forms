module Payments
  module Steps
    module Ac
      class ClaimedCostsForm < BasePaymentsForm
        attribute :claimed_net_assigned_counsel_cost, :gbp
        attribute :claimed_assigned_counsel_vat, :gbp
        attribute :claimed_total, :gbp

        validates :claimed_net_assigned_counsel_cost, :claimed_assigned_counsel_vat,
                  presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true

        def save
          return false unless valid?

          attribute_names.excluding(:claimed_total).each do |attr|
            multi_step_form_session[attr.to_sym] = public_send(attr) || 0
          end

          multi_step_form_session[:claimed_total] = calculated_costs

          true
        end
      end
    end
  end
end
