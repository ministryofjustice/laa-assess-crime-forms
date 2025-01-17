module Nsm
  class WorkItemsParams < BaseParamValidator
    attribute :id, :string
    attribute :claim_id, :string
    attribute :sort_by, :string
    attribute :sort_direction, :string
    attribute :page, :integer

    validates :claim_id, presence: true, is_a_uuid: true
    validates :sort_by, inclusion: {
                          in: %w[item cost date fee_earner claimed_time claimed_uplift
                                 claimed_net_cost allowed_net_cost]
                        },
      allow_nil: true
    validates :sort_direction, inclusion: { in: %w[ascending descending] }, allow_nil: true
    validates :page, numericality: { greater_than: 0 }, allow_nil: true
    validates :id, is_a_uuid: true, allow_nil: true
  end
end
