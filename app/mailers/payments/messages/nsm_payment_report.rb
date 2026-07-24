# frozen_string_literal: true

module Payments
  module Messages
    class NsmPaymentReport < Base
      def template
        '29db3a67-a5c0-454c-bdc4-0a8b0b9958a8'
      end

      def report_name
        'nsm_payment_report'
      end

      def metabase_question_id
        278
      end
    end
  end
end
