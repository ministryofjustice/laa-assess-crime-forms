module Payments
  class ClaimDetailsSummary < BaseCard
    CARD_ROWS = %i[
      claim_type
      date_received
      office_code
      ufn
      stage_reached
      defendant_first_name
      defendant_last_name
      number_of_defendants
      number_of_attendances
      hearing_outcome_code
      matter_type
      court
      youth_court
      date_completed
      laa_reference
    ].freeze

    def claim_type
      I18n.t("payments.requests.type.#{session_answers['request_type']}")
    end

    def date_received
      DateTime.parse(session_answers['date_received']).to_fs(:stamp)
    end

    def office_code
      session_answers['office_code']
    end

    def ufn
      session_answers['ufn']
    end

    def stage_reached
      session_answers['stage_reached']
    end

    def defendant_first_name
      session_answers['defendant_first_name']
    end

    def defendant_last_name
      session_answers['defendant_last_name']
    end

    def number_of_attendances
      session_answers['number_of_attendances']
    end

    def number_of_defendants
      session_answers['number_of_defendants']
    end

    def hearing_outcome_code
      session_answers['hearing_outcome_code']
    end

    def matter_type
      session_answers['matter_type']
    end

    def court
      session_answers['court']
    end

    def youth_court
      session_answers['youth_court']
    end

    def date_completed
      return unless session_answers['date_completed']

      DateTime.parse(session_answers['date_completed']).to_fs(:stamp)
    end

    def laa_reference
      session_answers['laa_reference']
    end
  end
end
