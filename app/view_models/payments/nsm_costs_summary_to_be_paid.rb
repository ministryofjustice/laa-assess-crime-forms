module Payments
  class NsmCostsSummaryToBePaid < NsmCostsSummary
    def heading
      I18n.t('payments.steps.check_your_answers.edit.costs_to_be_paid')
    end

    def headers
      [
        t('cost_type', numeric: false, width: '50%'),
        t('total_costs_to_be_paid'),
      ]
    end

    def formatted_summed_fields
      {
        name: t('total', numeric: false),
        total_costs_to_be_paid: format(session_answers['allowed_total'].to_f)
      }
    end

    def change_link
      url_helpers.edit_payments_steps_nsm_submission_allowed_costs_path(session_answers['id'])
    end

    private

    def build_row(type)
      {
        name: t(type, numeric: false),
        total_costs_to_be_paid: format(session_answers["allowed_#{type}"].to_f)
      }
    end
  end
end
