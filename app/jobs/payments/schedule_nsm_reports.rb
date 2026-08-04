module Payments
  class ScheduleNsmReports < Payments::ScheduleReportBase
    # Finance reconciliation team wants to receive this data from the earliest date possible
    # need to provide a date because it's needed by the Metabase API to generate the report.
    def start_date
      '2000-01-01'
    end

    def end_date
      DateTime.now.strftime('%Y-%m-%d')
    end

    def report_type
      'nsm'
    end

    def recipient_key
      'NSM_REPORT_EMAIL_ADDRESSES'
    end
  end
end
