module PriorAuthority
  class ChooseApplicationForAssignment
    class << self
      def call(user)
        criminal_court = "CASE WHEN data->>'court_type' = 'central_criminal_court' THEN 0 ELSE 1 END as criminal_court"
        pathologist_report = <<~SQL.squish
          CASE WHEN data->>'service_type' = 'pathologist_report' THEN 0 ELSE 1 END as pathologist_report
        SQL

        date_order_clause = Arel.sql("DATE_TRUNC('day', app_store_updated_at) ASC")

        PriorAuthorityApplication.assignable(user)
                                 .select('submissions.*', criminal_court, pathologist_report)
                                 .order(
                                   date_order_clause,
                                   criminal_court: :asc,
                                   pathologist_report: :asc,
                                   app_store_updated_at: :asc
                                 ).first
      end
    end
  end
end
