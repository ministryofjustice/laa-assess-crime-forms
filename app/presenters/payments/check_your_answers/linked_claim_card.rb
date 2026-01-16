module Payments
  module CheckYourAnswers
    class LinkedClaimCard < BaseCard
      attr_reader :session_answers

      def initialize(session_answers)
        @session_answers = session_answers

        @section = 'linked_claim'
        super()
      end

      def row_data
        [
          non_standard_magistrate,
          assigned_counsel
        ].flatten.compact
      end

      def assigned_counsel
        return unless session_answers['request_type'].in?(%w[assigned_counsel_appeal assigned_counsel_amendment])

        {
          head_key: 'assigned_counsel',
          text: session_answers['laa_reference'] ||
            I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_crm8')
        }
      end

      def non_standard_magistrate
        {
          head_key: 'non_standard_magistrate',
          text: linked_ref ||
            I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_crm7')
        }
      end

      private

      def linked_ref
        ref = nil
        if ac?
          ref = session_answers['linked_nsm_ref']
        elsif nsm_addition?
          ref = session_answers['laa_reference']
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
