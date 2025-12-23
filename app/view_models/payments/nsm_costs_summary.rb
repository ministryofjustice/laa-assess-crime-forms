module Payments
  class NsmCostsSummary < CostsSummary
    def table_fields
      [
        build_row(:profit_cost),
        build_row(:disbursement_cost),
        build_row(:travel_cost),
        build_row(:waiting_cost)
      ]
    end

    def change_link
      url_helpers.edit_payments_steps_nsm_claimed_costs_path(@id)
    end
  end
end
