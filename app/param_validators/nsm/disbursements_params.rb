module Nsm
  class DisbursementsParams < BaseParamValidator
    attribute :id, :string
    attribute :claim_id, :string
    attribute :sort_by, :string
    attribute :sort_direction, :string
    attribute :page, :integer

    validates :claim_id, presence: true
    validates :sort_by, inclusion: { in: %w[item cost claimed_net claimed_vat claimed_gross allowed_gross] },
allow_nil: true
    validates :sort_direction, inclusion: { in: %w[ascending descending] }, allow_nil: true
    validates :page, numericality: { greater_than: 0 }, allow_nil: true
  end
end
