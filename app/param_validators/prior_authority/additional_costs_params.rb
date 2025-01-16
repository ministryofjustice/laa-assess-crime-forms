module PriorAuthority
  class AdditionalCostsParams < BaseParamValidator
    attribute :id, :string
    attribute :application_id, :string

    validates :application_id, presence: true
  end
end
