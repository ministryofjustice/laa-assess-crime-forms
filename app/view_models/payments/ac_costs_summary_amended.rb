module Payments
  class AcCostsSummaryAmended < CostsSummaryAmended
    def heading
      I18n.t('payments.steps.check_your_answers.edit.amended_allowed_costs')
    end

    def headers
      [
        '',
        (t('original_total_allowed') if session_answers['claimed_total'].present?),
        t('total_allowed')
      ].compact
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

    def formatted_summed_fields
      {
        name: t('total', numeric: false),
        original_total_allowed: (if session_answers['claimed_total'].present?
                                   format(session_answers['original_allowed_total'].to_f)
                                 end),
        total_allowed: format(session_answers['allowed_total'].to_f)
      }.compact
    end

    private

    def build_row(type)
      {
        name: t(type, numeric: false),
        original_total_allowed: (if session_answers['claimed_total'].present?
                                   format(session_answers["original_allowed_#{type}"].to_f)
                                 end),
        total_allowed: format(session_answers["allowed_#{type}"].to_f)
      }.compact
    end
  end
end
