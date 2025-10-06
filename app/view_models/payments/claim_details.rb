module Payments
  class ClaimDetails
    def initialize(payment_request_claim)
      @payment_request_claim = payment_request_claim
    end

    def id
      @payment_request_claim['id']
    end

    def claim_type
      I18n.t("payments.claim_types.#{@payment_request_claim['claim_type']}")
    end

    def date_received
      DateTime.parse(@payment_request_claim['date_received']).to_fs(:stamp)
    end

    def office_code
      @payment_request_claim['office_code']
    end

    def firm_name
      @payment_request_claim['firm_name']
    end

    def ufn
      @payment_request_claim['ufn']
    end

    def stage_reached
      @payment_request_claim['stage_reached']
    end

    def defendant_first_name
      @payment_request_claim['defendant_first_name']
    end

    def defendant_last_name
      @payment_request_claim['defendant_last_name']
    end

    def number_of_attendances
      @payment_request_claim['number_of_attendances']
    end

    def number_of_defendants
      @payment_request_claim['number_of_defendants']
    end

    def hearing_outcome_code
      @payment_request_claim['hearing_outcome_code']
    end

    def matter_type
      @payment_request_claim['matter_type']
    end

    def court
      @payment_request_claim['court']
    end

    def youth_court
      @payment_request_claim['youth_court']
    end

    def laa_reference
      @payment_request_claim['laa_reference']
    end

    def last_updated
      DateTime.parse(@payment_request_claim['updated_at']).to_fs(:stamp)
    end

    def payment_requests
      @payment_request_claim['payment_requests']
        .map { Payments::PaymentRequestDetails.new(_1) }
        .sort_by(&:date_completed).reverse
    end

    def current_total
      payment_requests.last.allowed_total
    end
  end
end
