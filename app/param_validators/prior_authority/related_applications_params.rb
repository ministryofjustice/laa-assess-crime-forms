module PriorAuthority
  class RelatedApplicationsParams < BaseParamValidator
    attribute :application_id, :string
    attribute :sort_by, :string
    attribute :sort_direction, :string

    validates :sort_by, inclusion: { in: %w[laa_reference service_name client_name last_updated status_with_assignment] },
allow_nil: true
    validates :sort_direction, inclusion: { in: %w[ascending descending] }, allow_nil: true
  end
end
