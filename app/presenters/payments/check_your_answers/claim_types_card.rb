module Payments
  module CheckYourAnswers
    class ClaimTypesCard < BaseCard
      attr_reader :session_answers

      def initialize(session_answers)
        @session_answers = session_answers

        @section = 'claim_types'
        super()
      end

      def row_data
        [
          claim_type
        ]
      end

      def claim_type
        {
          head_key: 'claim_type',
          text: I18n.t("payments.requests.type.#{session_answers['request_type']}")
        }
      end
    end
  end
end
