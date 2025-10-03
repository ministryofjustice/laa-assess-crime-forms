module Payments
  class PaymentRequestDetails
    def initialize(payment_request)
      @payment_request = payment_request
    end

    def id
      @payment_request['id']
    end

    def request_type
      I18n.t("payments.request_types.#{@payment_request['request_type']}")
    end

    def title
      I18n.t("payments.requests.payment_details.payment_heading.#{@payment_request['request_type']}")
    end

    def date_received
      DateTime.parse(@payment_request['date_received']).to_fs(:stamp)
    end

    def date_completed
      DateTime.parse(@payment_request['submitted_at']).to_fs(:stamp)
    end

    def allowed_total
      LaaCrimeFormsCommon::NumberTo.pounds([
        @payment_request['allowed_profit_cost'],
        @payment_request['allowed_travel_cost'],
        @payment_request['allowed_waiting_cost'],
        @payment_request['allowed_disbursement_cost']
      ].sum)
    end

    def cost_summary
      @cost_summary ||= Payments::CostsSummary.new(@payment_request)
    end
  end
end
