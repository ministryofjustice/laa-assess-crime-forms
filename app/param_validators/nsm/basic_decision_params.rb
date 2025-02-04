module Nsm
  class BasicDecisionParams < BaseParamValidator
    attribute :claim_id, :string
    attribute :save_and_exit, :boolean

    validates :claim_id, presence: true, is_a_uuid: true
  end
end
