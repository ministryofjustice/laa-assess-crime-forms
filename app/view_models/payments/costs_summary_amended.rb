module Payments
  class CostsSummaryAmended < CostsSummary
    def headers
      [
        '',
        t('original_total_allowed'),
        t('total_allowed')
      ]
    end

    def formatted_summed_fields
      {
        name: t('total', numeric: false),
        original_total_allowed: format(session_answers['original_allowed_total'].to_f),
        total_allowed: format(session_answers['allowed_total'].to_f)
      }
    end

    private

    def build_row(type)
      {
        name: t(type, numeric: false),
        original_total_allowed: format(session_answers["original_allowed_#{type}"].to_f),
        total_allowed: format(session_answers["allowed_#{type}"].to_f)
      }
    end
  end
end
