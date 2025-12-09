module Payments
  class NsmCostsSummary < BaseCard
    include Routing

    PROFIT_COSTS = 'profit_costs'.freeze

    def heading
      I18n.t("payments.steps.check_your_answers.edit.claimed_and_allowed_costs")
    end

    def headers
      [
        '',
        t('total_claimed'),
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
        total_claimed: format(session_answers['claimed_total'].to_f),
        total_allowed: format(session_answers['allowed_total'].to_f)
      }
    end

    def change_link
      url_helpers.edit_payments_steps_nsm_claimed_costs_path(@id)
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
        total_allowed: format(session_answers["allowed_#{type}"].to_f)
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end
  end
end
