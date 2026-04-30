module Payments
  class CostsSummaryAmended < CostsSummary
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

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

    # :nocov:
    def table_fields
      raise 'implement this action, if needed, in subclasses'
    end

    def change_link
      raise 'implement this action, if needed, in subclasses'
    end
    # :nocov:

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
