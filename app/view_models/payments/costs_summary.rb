module Payments
  class CostsSummary
    include Routing

    attr_reader :session_answers

    PROFIT_COSTS = 'profit_costs'.freeze

    def initialize(session_answers)
      @session_answers = session_answers
    end

    def heading
      I18n.t('payments.steps.check_your_answers.edit.claimed_and_allowed_costs')
    end

    def headers
      [
        '',
        t('total_claimed'),
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
        total_claimed: format(session_answers['claimed_total'].to_f),
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
        total_claimed: format(session_answers["claimed_#{type}"].to_f),
        total_allowed: format(session_answers["allowed_#{type}"].to_f)
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end
  end
end
