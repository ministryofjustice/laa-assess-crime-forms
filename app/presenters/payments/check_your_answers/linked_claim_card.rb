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
            I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_claim')
        }
      end

      def non_standard_magistrate
        linked_ref = ac? ? session_answers['linked_nsm_claim'] : session_answers['laa_reference']
        return nil unless linked_ref

        {
          head_key: 'non_standard_magistrate',
          text: linked_ref ||
            I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_claim')
        }
      end

      private

      def ac?
        session_answers['request_type'].in?(%w[assigned_counsel assigned_counsel_appeal assigned_counsel_amendment])
      end
    end
  end
end
