module Payments
  class CostsSummary < BaseCard
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    # NOTE: this class can either take the multi form session storage object
    # or a payment_request object from the app store to prevent code replication
    # feel free to create 2 separate classes instead of the data structures diverge

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
        total_claimed: format(total_claimed_costs),
        total_allowed: format(total_allowed_costs),
      }
    end

    def calculated_allowed_costs
      [
        session_answers['allowed_profit_cost']&.to_f,
        session_answers['allowed_travel_cost']&.to_f,
        session_answers['allowed_waiting_cost']&.to_f,
        session_answers['allowed_disbursement_cost']&.to_f
      ].compact.sum
    end

    private

    def t(key, numeric: true, width: nil)
      {
        text: I18n.t("payments.steps.check_your_answers.show.#{key}"),
        numeric: numeric,
        width: width
      }
    end

    def build_row(type)
      {
        name: t(type, numeric: false),
        total_claimed: format((session_answers["claimed_#{type}"] || session_answers[type.to_s.singularize]).to_f),
        total_allowed: format((session_answers["allowed_#{type}"] || session_answers["allowed_#{type}".singularize]).to_f),
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end

    def total_claimed_costs
      session_answers['total_claimed_costs']&.to_f || calculated_claimed_costs
    end

    def total_allowed_costs
      session_answers['total_allowed_costs']&.to_f || calculated_allowed_costs
    end

    def calculated_claimed_costs
      [
        session_answers['profit_cost']&.to_f,
        session_answers['travel_cost']&.to_f,
        session_answers['waiting_cost']&.to_f,
        session_answers['disbursement_cost']&.to_f
      ].compact.sum
    end
  end
end
