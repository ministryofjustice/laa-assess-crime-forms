module Payments
  module CheckYourAnswers
    class ClaimDetailsCard < BaseCard
      include PaymentsHelper

      attr_reader :session_answers, :params

      def initialize(session_answers, params)
        @session_answers = session_answers
        @params = params

        @section = 'claim_details'
        super()
      end

      def linked_non_standard_magistrate
        {
          head_key: 'linked_non_standard_magistrate',
          text: linked_ref ||
            I18n.t('payments.steps.check_your_answers.edit.sections.claim_details.no_linked_crm7')
        }
      end

      private

      def linked_ref
        ref = nil
        if ac?
          ref = session_answers['linked_nsm_reference']
        elsif nsm_addition?
          ref = session_answers['linked_laa_reference'] || session_answers['laa_reference']
        elsif nsm_original?
          ref = session_answers['linked_laa_reference']
        # :nocov:
        else
          false
        end
        # :nocov:
        ref.presence
      end

      def ac?
        session_answers['request_type'].in?(%w[assigned_counsel assigned_counsel_appeal assigned_counsel_amendment])
      end

      def nsm_addition?
        session_answers['request_type'].in?(%w[non_standard_mag_amendment non_standard_mag_appeal non_standard_mag_supplemental])
      end

      def nsm_original?
        session_answers['request_type'].in?(%w[non_standard_magistrate breach_of_injunction])
      end
    end
  end
end
