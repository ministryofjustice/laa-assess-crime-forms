module PriorAuthority
  class BasicApplicationParams < BaseParamValidator
    attribute :application_id, :string

    validates :application_id, presence: true, is_a_uuid: true
  end
end
