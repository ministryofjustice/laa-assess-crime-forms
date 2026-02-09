module Payments
  module CheckYourAnswers
    class ClaimDetailsCard < BaseCard
      attr_reader :session_answers

      def initialize(session_answers)
        @session_answers = session_answers

        @section = 'claim_details'
        super()
      end

      def row_data
        [
          date_received, solicitor_office_code,
          ufn, stage_reached, defendant_first_name,
          defendant_last_name, number_of_attendances,
          number_of_defendants, hearing_outcome_code,
          matter_type, court, youth_court,
          date_completed,
        ].flatten.compact
      end

      def date_received
        {
          head_key: 'date_received',
          text: DateTime.parse(session_answers['date_received']).to_fs(:stamp)
        }
      end

      def solicitor_office_code
        {
          head_key: 'solicitor_office_code',
          text: session_answers['solicitor_office_code']
        }
      end

      def ufn
        {
          head_key: 'ufn',
          text: session_answers['ufn']
        }
      end

      def stage_reached
        {
          head_key: 'stage_reached',
          text: session_answers['stage_reached']
        }
      end

      def defendant_first_name
        {
          head_key: 'defendant_first_name',
          text: session_answers['defendant_first_name']
        }
      end

      def defendant_last_name
        {
          head_key: 'defendant_last_name',
          text: session_answers['defendant_last_name']
        }
      end

      def number_of_attendances
        {
          head_key: 'number_of_attendances',
          text: session_answers['number_of_attendances']
        }
      end

      def number_of_defendants
        {
          head_key: 'number_of_defendants',
          text: session_answers['number_of_defendants']
        }
      end

      def hearing_outcome_code
        {
          head_key: 'hearing_outcome_code',
          text: session_answers['hearing_outcome_code']
        }
      end

      def matter_type
        {
          head_key: 'matter_type',
          text: I18n.t(".laa_crime_forms_common.nsm.matter_type.#{session_answers['matter_type']}")
        }
      end

      def court
        {
          head_key: 'court',
          text: session_answers['court']
        }
      end

      def youth_court
        {
          head_key: 'youth_court',
          text: session_answers['youth_court']
        }
      end

      def date_completed
        return unless session_answers['date_completed']

        {
          head_key: 'date_completed',
          text: DateTime.parse(session_answers['date_completed']).to_fs(:stamp)
        }
      end

      def change_link_controller_path
        "payments/steps/nsm/#{section}"
      end

      def read_only?
        session_answers['linked_laa_reference'].present?
      end
    end
  end
end
