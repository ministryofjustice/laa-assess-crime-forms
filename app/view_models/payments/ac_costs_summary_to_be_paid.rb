module Payments
  class AcCostsSummaryToBePaid < AcCostsSummary
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

    private

    def build_row(type)
      {
        name: t(type, numeric: false),
        total_costs_to_be_paid: format(session_answers["allowed_#{type}"].to_f)
      }
    end
  end
end
