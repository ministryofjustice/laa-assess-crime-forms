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
        @directory_path = Rails.root.join('tmp/uploaded/').to_s
        FileUtils.mkdir_p(@directory_path) unless File.directory?(@directory_path)
      end

      def template
        '29db3a67-a5c0-454c-bdc4-0a8b0b9958a8'
      end

      def contents
        filename = "finance_report_#{@start_date}_to_#{@end_date}.csv"
        file_path = prepare_file(filename)
        File.open(file_path, 'rb') do |file|
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

      private

      def prepare_file(filename)
        file_path = File.join(@directory_path, filename)
        csv_download = MetabaseApiClient.new.download_question(278, @start_date, @end_date)
        csv_content = csv_download.body
        File.binwrite(file_path, csv_content)
        file_path
      end
    end
  end
end
