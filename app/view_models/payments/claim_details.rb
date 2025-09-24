module Payments
  class ClaimDetails
    def initialize(payment_request_claim)
      @payment_request_claim = payment_request_claim
    end


    def claim_type
      I18n.t("payments.requests.type.#{@payment_request_claim['claim_type']}")
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

    def date_completed
      return unless @payment_request_claim['date_completed']

      DateTime.parse(@payment_request_claim['date_completed']).to_fs(:stamp)
    end

    def laa_reference
      @payment_request_claim['laa_reference']
    end
  end
end
