# frozen_string_literal: true

module Payments
  module Messages
    class NsmPaymentReport < Base
      def template
        ENV.fetch('NSM_REPORT_EMAIL_TEMPLATE_ID', nil)
      end

      def report_name
        'nsm_payment_report'
      end

      def metabase_question_id
        ENV.fetch('METABASE_NSM_PAYMENT_DASHBOARD_ID', nil)
      end
    end
  end
end
