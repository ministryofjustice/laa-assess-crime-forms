module Payments
  class ScheduleNsmReports < ApplicationJob
    sidekiq_options retry: 5

    # rubocop:disable Metrics/AbcSize
    def perform
      start_date = '2000-01-01' # We likely don't have data this early but we want to ensure we capture all data
      end_date = DateTime.now.strftime('%Y-%m-%d')

      Rails.logger.info "Running Payments::ScheduleNsmReports at #{Time.zone.now}"
      recipients.each do |recipient|
        NsmReportMailer.notify(start_date, end_date, recipient).deliver_now
        Rails.logger.info "Sent email to #{recipient} at #{Time.zone.now}"
      end
      Rails.logger.info 'Clearing tmp/uploaded/reports directory'
      FileUtils.rm_rf(Rails.root.join('tmp/uploaded/reports'))
      Rails.logger.info 'Cleared tmp/uploaded/reports directory'
    end
    # rubocop:enable Metrics/AbcSize

    private

    def recipients
      ENV.fetch('NSM_REPORT_EMAIL_ADDRESSES', nil).split(',').map(&:strip)
    end
  end
end
