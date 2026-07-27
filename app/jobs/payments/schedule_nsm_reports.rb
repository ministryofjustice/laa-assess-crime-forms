module Payments
  class ScheduleNsmReports < ApplicationJob
    def start_date
      '2000-01-01'
    end

    def end_date
      DateTime.now.strftime('%Y-%m-%d')
    end

    def report_type
      'nsm'
    end

    def recipients
      ENV.fetch('NSM_REPORT_EMAIL_ADDRESSES', nil).split(',').map(&:strip)
    end
  end
end
