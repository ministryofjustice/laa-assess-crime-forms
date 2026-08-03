# frozen_string_literal: true

module Payments
  module Messages
    class AcPaymentReport < Base
      def template
        ENV.fetch('AC_REPORT_EMAIL_TEMPLATE_ID', nil)
      end

      def report_name
        'ac_payment_report'
      end

      def metabase_question_id
        ENV.fetch('METABASE_AC_PAYMENT_DASHBOARD_ID', nil)
      end
    end
  end
end
