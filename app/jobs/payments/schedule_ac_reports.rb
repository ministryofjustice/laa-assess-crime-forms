module Payments
  class ScheduleAcReports < Payments::ScheduleReportBase
    def start_date
      (DateTime.now - 15).strftime('%Y-%m-%d')
    end

    def end_date
      (DateTime.now - 1).strftime('%Y-%m-%d')
    end

    def recipient_key
      'AC_REPORT_EMAIL_ADDRESSES'
    end

    def report_type
      'ac'
    end
  end
end
