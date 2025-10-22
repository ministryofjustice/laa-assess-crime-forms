module Payments
  class BaseClaimDetails
    def initialize(payment_request_claim, related_payment_params)
      @payment_request_claim = payment_request_claim
      @related_payment_params = related_payment_params
    end

    def id
      @payment_request_claim['id']
    end

    def claim_type
      I18n.t("shared.claim_type.#{@payment_request_claim['type']}")
    end

    def date_received
      DateTime.parse(@payment_request_claim['date_received']).to_fs(:stamp)
    end

    def laa_reference
      @payment_request_claim['laa_reference']
    end

    def last_updated
      # Note from CRM7-2702, this assumes that the last change to a payment request claim
      # is the submission of the last payment. This method needs updating if other processes
      # are ever added to payment request claims

      payment_requests.first.date_completed
    end

    def payment_requests
      @payment_requests ||= @payment_request_claim['payment_requests']
                            .map { Payments::PaymentRequestDetails.new(_1, @payment_request_claim['type']) }
                            .sort_by(&:submitted_date).reverse
    end

    def current_total
      payment_requests.first.allowed_total
    end

    def related_payments
      if @payment_request_claim['assigned_counsel_claim']
        Payments::RelatedPayments.new(@payment_request_claim['assigned_counsel_claim'], @related_payment_params)
      elsif @payment_request_claim['nsm_claim']
        Payments::RelatedPayments.new(@payment_request_claim['nsm_claim'], @related_payment_params)
      else
        []
      end
    end

    private

    def table_heading(key)
      I18n.t("payments.requests.claim_details.table.#{key}")
    end
  end
end
