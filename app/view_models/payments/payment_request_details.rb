module Payments
  class PaymentRequestDetails
    def initialize(payment_request, claim_type)
      @payment_request = payment_request
      @claim_type = claim_type
    end

    def id
      @payment_request['id']
    end

    def request_type
      I18n.t("payments.request_types.#{@payment_request['request_type']}")
    end

    def date_received_label
      I18n.t("payments.requests.payment_details.date_received.#{@payment_request['request_type']}")
    end

    def title
      I18n.t("payments.requests.payment_details.payment_heading.#{@payment_request['request_type']}")
    end

    def date_received
      DateTime.parse(@payment_request['date_received']).to_fs(:stamp)
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
      @cost_summary ||= Payments::ViewCostsSummary.new(@payment_request, @claim_type)
    end
  end
end
