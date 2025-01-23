module Nsm
  class AdditionalFeesParams < BaseParamValidator
    attribute :id, :string
    attribute :claim_id, :string

    validates :id, inclusion: { in: %w[youth_court_fee] }, allow_nil: true
    validates :claim_id, presence: true, is_a_uuid: true
  end
end
