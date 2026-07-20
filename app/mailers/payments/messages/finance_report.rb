# frozen_string_literal: true

module Payments
  module Messages
    class FinanceReport
      def initialize(start_date, end_date)
        @start_date = start_date
        @end_date = end_date
      end

      def template
        '29db3a67-a5c0-454c-bdc4-0a8b0b9958a8'
      end

      def contents
        {
          start_date: @start_date,
          end_date: @end_date,
        }
      end

      def recipient
        ENV.fetch('FINANCE_EMAIL_ADDRESS', nil)
      end
    end
  end
end
