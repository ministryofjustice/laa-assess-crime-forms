# frozen_string_literal: true

module Payments
  module Messages
    class Base
      def initialize(start_date, end_date)
        begin
          start_date = Date.parse(start_date)
          end_date = Date.parse(end_date)
        rescue ArgumentError
          raise 'start_date and end_date must be valid dates in YYYY-MM-DD format'
        end

        @start_date = start_date
        @end_date = end_date
        @directory_path = Rails.root.join('tmp/uploaded/reports').to_s
        FileUtils.mkdir_p(@directory_path) unless File.directory?(@directory_path)
      end

      def template
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def report_name
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def metabase_question_id
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def contents
        filename = "#{report_name}_#{@start_date}_to_#{@end_date}.csv"
        file_path = File.join(@directory_path, filename)
        prepare_file(filename) unless File.exist?(file_path)
        File.open(file_path, 'rb') do |file|
          {
            start_date: @start_date,
            end_date: @end_date,
            link_to_file: Notifications.prepare_upload(file, filename:)
          }
        end
      end

      private

      def prepare_file(filename)
        file_path = File.join(@directory_path, filename)
        csv_download = MetabaseApiClient.new.download_question(metabase_question_id, @start_date, @end_date)
        File.binwrite(file_path, csv_download)
        file_path
      end
    end
  end
end
