module Payments
  class ScheduleReportBase < ApplicationJob
    sidekiq_options retry: 5

    # rubocop:disable-next Metrics/AbcSize
    def perform
      return unless FeatureFlags.payments.enabled?

      Rails.logger.info "Running #{self.class} at #{Time.zone.now}"
      recipients.each do |recipient|
        Payments::EmailPaymentReportMailer.notify(report_type, start_date, end_date, recipient).deliver_now
        Rails.logger.info "Sent email to #{recipient} at #{Time.zone.now}"
      end
      Rails.logger.info 'Clearing tmp/uploaded/reports directory'
      FileUtils.rm_rf(Rails.root.join('tmp/uploaded/reports'))
      Rails.logger.info 'Cleared tmp/uploaded/reports directory'
    end

    def recipient_key
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def recipients
      ENV.fetch(recipient_key, '').split(',').map(&:strip).compact_blank
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
