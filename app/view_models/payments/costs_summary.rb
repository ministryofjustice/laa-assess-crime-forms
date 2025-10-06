module Payments
  class CostsSummary < BaseCard
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    PROFIT_COSTS = 'profit_costs'.freeze

    def headers
      [
        '',
        t('total_claimed'),
        t('total_allowed'),
      ]
    end

    def table_fields
      [
        build_row(:profit_costs),
        build_row(:disbursement_costs),
        build_row(:travel_costs),
        build_row(:waiting_costs)
      ]
    end

    def formatted_summed_fields
      {
        name: t('total', numeric: false),
        total_claimed: format(session_answers['total_claimed_costs'].to_f),
        total_allowed: format(session_answers['total_allowed_costs'].to_f),
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
        total_claimed: format(session_answers["claimed_#{type}"].to_f),
        total_allowed: format(session_answers["allowed_#{type}"].to_f),
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end
  end
end
