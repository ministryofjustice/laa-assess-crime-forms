module Payments
  class ScheduleFinanceReports < ApplicationJob
    sidekiq_options retry: 5

    def perform
      Rails.logger.info "Running Payments::ScheduleFinanceReports at #{Time.zone.now}"
      EmailToFinanceMailer.notify('start_date', 'end_date').deliver_now
    end
  end
end
