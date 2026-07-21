module Payments
  class ScheduleFinanceReports < ApplicationJob
    sidekiq_options retry: 5

    def perform
      Rails.logger.info "Running Payments::ScheduleFinanceReports at #{Time.zone.now}"
      EmailToFinanceMailer.notify('2026-01-01', '2026-08-01').deliver_now
    end
  end
end
