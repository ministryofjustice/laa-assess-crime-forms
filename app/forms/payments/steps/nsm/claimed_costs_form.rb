module Payments
  module Steps
    module Nsm
      class ClaimedCostsForm < BasePaymentsForm
        attribute :profit_costs, :gbp
        attribute :disbursement_costs, :gbp
        attribute :travel_costs, :gbp
        attribute :waiting_costs, :gbp

        validates :profit_costs, :disbursement_costs,
                  :travel_costs, :waiting_costs, presence: true, numericality: { greater_than: 0 }, is_a_number: true
      end
    end
  end
end
