module PriorAuthority
  class CostsParams < BaseParamValidator
    attribute :id, :string
    attribute :application_id, :string

    validates :application_id, presence: true, is_a_uuid: true
  end
end
