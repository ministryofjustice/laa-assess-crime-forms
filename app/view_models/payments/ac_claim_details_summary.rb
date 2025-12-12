module Payments
  class AcClaimDetailsSummary < BaseCard
    CARD_ROWS = %i[
      claim_type
      linked_claim
      date_received
      solicitor_office_code
      solicitor_firm_name
      ufn
      defendant_last_name
      counsel_office_code
      counsel_firm_name
    ].freeze

    def claim_type
      I18n.t("payments.requests.type.#{session_answers['request_type']}")
    end

    def date_received
      DateTime.parse(session_answers['date_received']).to_fs(:stamp)
    end

    def solicitor_office_code
      session_answers['solicitor_office_code']
    end

    def solicitor_firm_name
      session_answers['solicitor_firm_name']
    end

    def ufn
      session_answers['ufn']
    end

    def defendant_last_name
      session_answers['defendant_last_name']
    end

    def linked_claim
      session_answers['laa_reference'] || I18n.t('payments.no_linked_claim')
    end

    def counsel_office_code
      session_answers['counsel_office_code']
    end

    def counsel_firm_name
      session_answers['counsel_firm_name']
    end
  end
end
