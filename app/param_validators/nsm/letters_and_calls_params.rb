module Nsm
  class LettersAndCallsParams < BaseParamValidator
    attribute :claim_id, :string
    attribute :id, :string

    validates :claim_id, presence: true
    validates :id, inclusion: { in: %w[letters calls] }, allow_nil: true
  end
end
