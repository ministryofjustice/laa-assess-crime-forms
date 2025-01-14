module Nsm
  class BasicClaimParams < BaseParamValidator
    attribute :claim_id, :string

    validates :claim_id, presence: true
  end
end
