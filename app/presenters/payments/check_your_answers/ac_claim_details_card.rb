module Payments
  module CheckYourAnswers
    class AcClaimDetailsCard < BaseCard
      attr_reader :session_answers

      def initialize(session_answers)
        @session_answers = session_answers

        @section = 'claim_details'
        super()
      end

      def row_data
        [
          date_received,
          solicitor_office_code,
          solicitor_firm_name,
          ufn,
          defendant_last_name,
          counsel_office_code,
          counsel_firm_name
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

      def change_link_url_options
        { return_to_cya: 1 }
      end

      def read_only?
        false
      end

      private

      def linked_claim?
        case session_answers['request_type']
        when 'assigned_counsel'
          session_answers['linked_nsm_ref'].present?
        when 'assigned_counsel_appeal', 'assigned_counsel_amendment'
          session_answers['laa_reference'].present?
        else
          false
        end
      end
    end
  end
end
