module Payments
  class NsmCostsSummary < CostsSummary
    def initialize(session_answers, from_submission: false)
      super(session_answers)
      @from_submission = from_submission
    end

    def table_fields
      [
        build_row(:profit_cost),
        build_row(:disbursement_cost),
        build_row(:travel_cost),
        build_row(:waiting_cost)
      ]
    end

    def change_link
      if @from_submission
        url_helpers.edit_payments_steps_nsm_submission_allowed_costs_path(session_answers['id'])
      else
        url_helpers.edit_payments_steps_nsm_claimed_costs_path(session_answers['id'])
      end
    end

    def change_link_text
      if @from_submission
        I18n.t('payments.steps.check_your_answers.edit.change_profit_cost')
      else
        I18n.t('payments.steps.check_your_answers.edit.change')
      end
    end
  end
end
