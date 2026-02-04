module Payments
  class CostsSummaryAmendedAndClaimed < CostsSummary
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    def heading
      I18n.t('payments.steps.check_your_answers.edit.claimed_and_allowed_costs')
    end

    def headers
      [
        '',
        t('original_total_claimed'),
        t('total_claimed'),
        t('original_total_allowed'),
        t('total_allowed')
      ]
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
        original_total_claimed: format(session_answers['original_claimed_total'].to_f),
        total_claimed: format(session_answers['claimed_total'].to_f),
        original_total_allowed: format(session_answers['original_allowed_total'].to_f),
        total_allowed: format(session_answers['allowed_total'].to_f)
      }
    end

    private

    def build_row(type)
      {
        name: t(type, numeric: false),
        original_total_claimed: format(session_answers["original_claimed_#{type}"].to_f),
        total_claimed: format(session_answers["claimed_#{type}"].to_f),
        original_total_allowed: format(session_answers["original_allowed_#{type}"].to_f),
        total_allowed: format(session_answers["allowed_#{type}"].to_f)
      }
    end
  end
end
