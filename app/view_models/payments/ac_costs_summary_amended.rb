module Payments
  class AcCostsSummaryAmended < CostsSummaryAmended
    def heading
      if session_answers['request_type'] == 'assigned_counsel_amendment'
        I18n.t('payments.steps.check_your_answers.edit.amended_allowed_costs')
      else
        I18n.t('payments.steps.check_your_answers.edit.allowed_costs')
      end
    end

    def table_fields
      [
        build_row(:net_assigned_counsel_cost),
        build_row(:assigned_counsel_vat)
      ]
    end

    def change_link
      url_helpers.edit_payments_steps_ac_allowed_costs_path(@id)
    end
  end
end
