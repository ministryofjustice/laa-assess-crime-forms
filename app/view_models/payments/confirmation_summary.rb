module Payments
  class ConfirmationSummary
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def claim_type
      I18n.t("payments.requests.type.#{response['payment_request']['request_type']}")
    end

    def amount_allowed
      LaaCrimeFormsCommon::NumberTo.pounds(response['payment_request']['allowed_total'].to_f)
    end

    def laa_reference
      response['claim']['laa_reference']
    end
  end
end
