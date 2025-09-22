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
                  presence: true, numericality: { greater_than: 0 }, is_a_number: true
      end
    end
  end
end
