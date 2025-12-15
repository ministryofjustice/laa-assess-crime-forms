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
        row = [
          non_standard_magistrate,
          assigned_counsel
        ]
        row.flatten.compact
      end

      def assigned_counsel
        # TODO: add coverage when AC flow implemented
        # :nocov:
        return unless session_answers['linked_crm8_laa_reference']

        {
          head_key: 'assigned_counsel',
          text: session_answers['linked_crm8_laa_reference'] ||
            I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_claim')
        }
        # :nocov:
      end

      def non_standard_magistrate
        {
          head_key: 'non_standard_magistrate',
          text: session_answers['linked_laa_reference'] ||
            session_answers['laa_reference'] ||
            I18n.t('payments.steps.check_your_answers.edit.sections.linked_claim.no_linked_claim')
        }
      end
    end
  end
end
