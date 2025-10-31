module Payments
  class CostsSummaryAmendedAndClaimed < BaseCard
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    PROFIT_COSTS = 'profit_costs'.freeze

    def headers
      [
        '',
        t('original_total_claimed'),
        t('total_claimed'),
        t('original_total_allowed'),
        t('total_allowed')
      ]
    end

    def table_fields
      [
        build_row(:profit_cost),
        build_row(:disbursement_cost),
        build_row(:travel_cost),
        build_row(:waiting_cost)
      ]
    end

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

    def t(key, numeric: true, width: nil)
      {
        text: I18n.t("payments.steps.check_your_answers.edit.#{key}"),
        numeric: numeric,
        width: width
      }
    end

    def build_row(type)
      {
        name: t(type, numeric: false),
        original_total_claimed: format(session_answers["original_claimed_#{type}"].to_f),
        total_claimed: format(session_answers["claimed_#{type}"].to_f),
        original_total_allowed: format(session_answers["original_allowed_#{type}"].to_f),
        total_allowed: format(session_answers["allowed_#{type}"].to_f)
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end
  end
end
