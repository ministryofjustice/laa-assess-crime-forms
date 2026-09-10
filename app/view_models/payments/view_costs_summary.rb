module Payments
  class ViewCostsSummary
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    NSM_COSTS = %w[
      profit_cost
      travel_cost
      waiting_cost
      disbursement_cost
    ].freeze

    ASSIGNED_COUNSEL_COSTS = %w[
      net_assigned_counsel_cost
      assigned_counsel_vat
    ].freeze

    def initialize(payment_request, claim_type)
      @payment_request = payment_request
      @claim_type = claim_type
    end

    def row_fields
      case @claim_type
      when 'NsmClaim'
        NSM_COSTS
      when 'AssignedCounselClaim'
        ASSIGNED_COUNSEL_COSTS
      else
        raise "Invalid payment claim type: #{@claim_type}"
      end
    end

    def headers
      if to_be_paid?
        [
          t('cost_type', numeric: false, width: '50%'),
          t('total_costs_to_be_paid')
        ]
      else
        [
          t('cost_type', numeric: false, width: '50%'),
          t('total_claimed'),
          t('total_allowed')
        ]
      end
    end

    def table_fields
      row_fields.map { build_row(_1) }
    end

    def formatted_summed_fields
      if to_be_paid?
        {
          name: t('total', numeric: false),
          total_costs_to_be_paid: format(calculated_allowed_costs)
        }
      else
        {
          name: t('total', numeric: false),
          total_claimed: format(calculated_claimed_costs),
          total_allowed: format(calculated_allowed_costs),
        }
      end
    end

    def calculated_allowed_costs
      row_fields.map { @payment_request["allowed_#{_1}"].to_f }.compact.sum
    end

    private

    def build_row(type)
      if to_be_paid?
        {
          name: t(type, numeric: false),
          to_be_paid: format(@payment_request["allowed_#{type}"].to_f)
        }
      else
        {
          name: t(type, numeric: false),
          total_claimed: format(@payment_request["claimed_#{type}"].to_f),
          total_allowed: format(@payment_request["allowed_#{type}"].to_f),
        }
      end
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end

    def calculated_claimed_costs
      row_fields.map { @payment_request["claimed_#{_1}"].to_f }.compact.sum
    end

    def t(key, numeric: true, width: nil)
      {
        text: I18n.t("payments.requests.payment_details.#{key}"),
        numeric: numeric,
        width: width
      }
    end

    def to_be_paid?
      @payment_request['calculation_method'] == LaaCrimeFormsCommon::PaymentBasis::ENTERED_TO_BE_PAID
    end
  end
end
