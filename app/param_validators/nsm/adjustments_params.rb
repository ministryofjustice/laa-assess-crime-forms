module Nsm
  class AssignmentsParams < BaseParamValidator
    attribute :claim_id, :string

    validates :claim_id, presence: true
  end
end
