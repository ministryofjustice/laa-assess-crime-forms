module Payments
  class AcCostsSummary < CostsSummary
    def table_fields
      [
        build_row(:net_assigned_counsel_cost),
        build_row(:assigned_counsel_vat)
      ]
    end

    def change_link
      url_helpers.edit_payments_steps_ac_claimed_costs_path(@id)
    end
  end
end
