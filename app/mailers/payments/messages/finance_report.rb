# frozen_string_literal: true

module Payments
  module Messages
    class FinanceReport
      def initialize(start_date, end_date)
        begin
          start_date = Date.parse(start_date)
          end_date = Date.parse(end_date)
        rescue ArgumentError
          raise 'start_date and end_date must be valid dates in YYYY-MM-DD format'
        end

        @start_date = start_date
        @end_date = end_date
      end

      def template
        '29db3a67-a5c0-454c-bdc4-0a8b0b9958a8'
      end

      def contents
        file_path = Rails.root.join('tmp/uploaded/').to_s
        filename = "finance_report_#{@start_date}_to_#{@end_date}.csv"
        File.open(File.join(file_path, filename), 'w') do |file|
          file.write(MetabaseApiClient.new.download_question(278, @start_date, @end_date))
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
