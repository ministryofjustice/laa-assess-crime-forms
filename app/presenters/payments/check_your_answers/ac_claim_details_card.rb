module Payments
  module CheckYourAnswers
    class AcClaimDetailsCard < BaseCard
      attr_reader :session_answers, :params

      def initialize(session_answers, params)
        @session_answers = session_answers
        @params = params

        @section = 'claim_details'
        super()
      end

      def row_data
        [
          date_claim_assessed,
          solicitor_office_code,
          solicitor_firm_name,
          ufn,
          defendant_last_name,
          counsel_office_code,
          counsel_firm_name
        ].flatten.compact
      end

      def date_claim_assessed
        {
          head_key: 'date_claim_assessed',
          text: DateTime.parse(session_answers['date_claim_assessed']).to_fs(:stamp)
        }
      end

      def solicitor_office_code
        {
          head_key: 'solicitor_office_code',
          text: session_answers['solicitor_office_code']
        }
      end

      def solicitor_firm_name
        {
          head_key: 'solicitor_firm_name',
          text: session_answers['solicitor_firm_name']
        }
      end

      def ufn
        {
          head_key: 'ufn',
          text: session_answers['ufn']
        }
      end

      def defendant_last_name
        {
          head_key: 'defendant_last_name',
          text: session_answers['defendant_last_name']
        }
      end

      def counsel_office_code
        {
          head_key: 'counsel_office_code',
          text: session_answers['counsel_office_code']
        }
      end

      def counsel_firm_name
        {
          head_key: 'counsel_firm_name',
          text: session_answers['counsel_firm_name']
        }
      end

      def change_link_controller_path
        if linked_claim?
          'payments/steps/claim_search'
        else
          'payments/steps/office_code_search'
        end
      end

      def change_link_session_id
        params['id']
      end

      def read_only?
        false
      end

      private

      def linked_claim?
        session_answers['linked_nsm_reference'].present? || session_answers['laa_reference'].present?
      end
    end
  end
end
