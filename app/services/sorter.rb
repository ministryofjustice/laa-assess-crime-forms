class Sorter
  # NOTE: applications in a 'submitted' state can be assigned and therefore "In progresss", or unassigned.
  # Unassigned applications require the visual label "Not assigned" for caseworker
  STATUS_ORDER_CLAUSE = <<-SQL.squish.freeze
  CASE WHEN state = 'submitted' THEN
         CASE WHEN users.id IS NULL THEN  'not_assigned'
         ELSE 'in_progress' END
       ELSE state END ?
  SQL

  CASEWORKER_ORDER_CLAUSE = <<-SQL.squish.freeze
    CASE WHEN users.id IS NULL THEN NULL
    ELSE users.first_name || ' ' || users.last_name END ? NULLS LAST
  SQL

  RISK_ORDER_CLAUSE = <<-SQL.squish.freeze
  CASE risk WHEN 'high' THEN 3
       WHEN 'medium' THEN 2
       ELSE 1 END ?
  SQL

  # Mimic Submission#last_updated_at
  UPDATED_ORDER_CLAUSE = <<-SQL.squish.freeze
    COALESCE(non_local_events.latest_timestamp, submissions.updated_at) ?
  SQL

  ORDERS = {
    'laa_reference' => "data->>'laa_reference' ?",
    'firm_name' => "data->'firm_office'->>'name' ?",
    'client_name' => "(data->'defendant'->>'first_name') || ' ' || (data->'defendant'->>'last_name') ?",
    'main_defendant_name' => "(defendants.value->>'first_name') || ' ' || (defendants.value->>'last_name') ?",
    'caseworker' => CASEWORKER_ORDER_CLAUSE,
    'status' => STATUS_ORDER_CLAUSE,
    'date_updated' => UPDATED_ORDER_CLAUSE,
    'risk' => RISK_ORDER_CLAUSE,
    'service_name' => "data->>'service_type' ?",
  }.freeze

  DIRECTIONS = {
    'descending' => 'DESC',
    'ascending' => 'ASC',
  }.freeze

  class << self
    def call(base_query, sort_by, sort_direction)
      order_template = ORDERS[sort_by]
      direction = DIRECTIONS[sort_direction]
      base_query.then { add_joins(_1, sort_by) }.order(Arel.sql(order_template.gsub('?', direction)))
    end

    def add_joins(query, sort_by)
      with_users = query.left_joins(assignments: :user)

      case sort_by
      when 'main_defendant_name'
        with_users.joins("CROSS JOIN JSONB_ARRAY_ELEMENTS(data->'defendants') as defendants")
                  .where("defendants.value->>'main' = 'true'")
      when 'date_updated'
        with_users.with(
          non_local_events: Event.non_local
                                 .group(:submission_id)
                                 .select('submission_id, MAX(created_at) as latest_timestamp')
        ).joins('LEFT JOIN non_local_events ON non_local_events.submission_id = submissions.id')
      else
        with_users
      end
    end
  end
end
