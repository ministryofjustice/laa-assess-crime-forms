module Payments
  class PaymentRequestDetails
    def initialize(payment_request, claim_type)
      @payment_request = payment_request
      @claim_type = claim_type
    end

    attr_reader :payment_request, :claim_type

    def id
      @payment_request['id']
    end

    def request_type
      I18n.t("payments.request_types.#{@payment_request['request_type']}")
    end

    def date_claim_assessed_label
      I18n.t("payments.requests.payment_details.date_claim_assessed.#{@payment_request['request_type']}")
    end

    def title
      if to_be_paid?
        I18n.t('payments.requests.payment_details.payment_heading.costs_to_be_paid')
      else
        I18n.t("payments.requests.payment_details.payment_heading.#{@payment_request['request_type']}")
      end
    end

    def date_claim_assessed
      DateTime.parse(@payment_request['date_claim_assessed']).to_fs(:stamp)
    end

    def submitted_date
      DateTime.parse(@payment_request['submitted_at'])
    end

    def date_completed
      DateTime.parse(@payment_request['submitted_at']).to_fs(:stamp)
    end

    def allowed_total
      LaaCrimeFormsCommon::NumberTo.pounds(cost_summary.calculated_allowed_costs)
    end

    def caseworker
      User.find(@payment_request['submitter_id']).display_name
    end

    def cost_summary
      @cost_summary ||= Payments::ViewCostsSummary.new(self)
    end

    def calculation_method
      @payment_request['calculation_method']
    end

    def to_be_paid?
      return false if @payment_request['request_type'].in? %w[non_standard_magistrate assigned_counsel breach_of_injunction]

      calculation_method == LaaCrimeFormsCommon::PaymentBasis::ENTERED_TO_BE_PAID
    end
  end
end
