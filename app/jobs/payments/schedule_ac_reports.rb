module Payments
  class ScheduleAcReports < ApplicationJob
    sidekiq_options retry: 5

    # rubocop:disable Metrics/AbcSize
    def perform
      end_date = (DateTime.now - 1).strftime('%Y-%m-%d')
      start_date = (DateTime.now - 15).strftime('%Y-%m-%d')
      Rails.logger.info "Running Payments::ScheduleAcReports at #{Time.zone.now}"
      recipients.each do |recipient|
        Payments::EmailPaymentReportMailer.notify('ac', start_date, end_date, recipient).deliver_now
        Rails.logger.info "Sent email to #{recipient} at #{Time.zone.now}"
      end
      Rails.logger.info 'Clearing tmp/uploaded/reports directory'
      FileUtils.rm_rf(Rails.root.join('tmp/uploaded/reports'))
      Rails.logger.info 'Cleared tmp/uploaded/reports directory'
    end
    # rubocop:enable Metrics/AbcSize

    private

    def recipients
      ENV.fetch('AC_REPORT_EMAIL_ADDRESSES', nil).split(',').map(&:strip)
    end
  end
end
