module Payments
  class CostsSummary < BaseCard
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    PROFIT_COSTS = 'profit_costs'.freeze

    def initialize(cost_details)
      @cost_details = cost_details
    end

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
        @cost_details['allowed_profit_cost']&.to_f,
        @cost_details['allowed_travel_cost']&.to_f,
        @cost_details['allowed_waiting_cost']&.to_f,
        @cost_details['allowed_disbursement_cost']&.to_f
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
        total_claimed: format((@cost_details["claimed_#{type}"] || @cost_details[type.to_s.singularize]).to_f),
        total_allowed: format((@cost_details["allowed_#{type}"] || @cost_details["allowed_#{type}".singularize]).to_f),
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end

    def total_claimed_costs
      @cost_details['total_claimed_costs']&.to_f || calculated_claimed_costs
    end

    def total_allowed_costs
      @cost_details['total_allowed_costs']&.to_f || calculated_allowed_costs
    end

    def calculated_claimed_costs
      [
        @cost_details['profit_cost']&.to_f,
        @cost_details['travel_cost']&.to_f,
        @cost_details['waiting_cost']&.to_f,
        @cost_details['disbursement_cost']&.to_f
      ].compact.sum
    end
  end
end
