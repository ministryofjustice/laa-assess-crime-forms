module Payments
  class ViewCostsSummary
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    def initialize(payment_request, claim_type)
      @payment_request = payment_request
      @claim_type = claim_type
    end

    def row_fields
      if @claim_type == 'NsmClaim'
        %w[
          profit_cost
          travel_cost
          waiting_cost
          disbursement_cost
        ]
      elsif @claim_type == 'AssignedCounselClaim'
        %w[
          net_assigned_counsel_cost
          assigned_counsel_vat
        ]
      end
    end

    def headers
      [
        '',
        t('total_claimed'),
        t('total_allowed'),
      ]
    end

    def table_fields
      row_fields.map { build_row(_1) }
    end

    def formatted_summed_fields
      {
        name: t('total', numeric: false),
        total_claimed: format(calculated_claimed_costs),
        total_allowed: format(calculated_allowed_costs),
      }
    end

    def calculated_allowed_costs
      row_fields.map { @payment_request["allowed_#{_1}"]&.to_f }.compact.sum
    end

    private

    def build_row(type)
      {
        name: t(type, numeric: false),
        total_claimed: format(@payment_request[type].to_f),
        total_allowed: format(@payment_request["allowed_#{type}"].to_f),
      }
    end

    def format(value)
      { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
    end

    def calculated_claimed_costs
      row_fields.map { @payment_request[_1]&.to_f }.compact.sum
    end

    def t(key, numeric: true, width: nil)
      {
        text: I18n.t("payments.requests.payment_details.#{key}"),
        numeric: numeric,
        width: width
      }
    end
  end
end
