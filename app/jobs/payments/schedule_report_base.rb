module Payments
  class ScheduleReportBase < ApplicationJob
    sidekiq_options retry: 5

    # rubocop:disable Metrics/AbcSize
    def perform
      Rails.logger.info "Running #{self.class} at #{Time.zone.now}"
      recipients.each do |recipient|
        Payments::EmailPaymentReportMailer.notify(report_type, start_date, end_date, recipient).deliver_now
        Rails.logger.info "Sent email to #{recipient} at #{Time.zone.now}"
      end
      Rails.logger.info 'Clearing tmp/uploaded/reports directory'
      FileUtils.rm_rf(Rails.root.join('tmp/uploaded/reports'))
      Rails.logger.info 'Cleared tmp/uploaded/reports directory'
    end
    # rubocop:enable Metrics/AbcSize

    def recipients
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def start_date
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def end_date
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def report_type
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
