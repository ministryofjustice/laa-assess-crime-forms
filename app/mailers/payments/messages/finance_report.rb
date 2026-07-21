# frozen_string_literal: true

module Payments
  module Messages
    class FinanceReport
      def initialize(start_date, end_date)
        raise 'start_date must be a Date' unless start_date.is_a?(Date)
        raise 'end_date must be a Date' unless end_date.is_a?(Date)

        @start_date = start_date
        @end_date = end_date
      end

      def template
        '29db3a67-a5c0-454c-bdc4-0a8b0b9958a8'
      end

      def contents
        filename = "finance_report_#{@start_date}_to_#{@end_date}.csv"
        File.open(filename, 'w') do |file|
          file.write(MetabaseApiClient.new.get_finance_report_csv(@start_date, @end_date))
          {
            start_date: @start_date,
            end_date: @end_date,
            link_to_file: Notifications.prepare_upload(file, filename:)
          }
        end
      end

      def recipient
        ENV.fetch('FINANCE_EMAIL_ADDRESS', nil)
      end
    end
  end
end
