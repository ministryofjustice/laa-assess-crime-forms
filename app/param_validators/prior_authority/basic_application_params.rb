module PriorAuthority
  class BasicApplicationParams < BaseParamValidator
    attribute :application_id, :string

    validates :application_id, presence: true
  end
end
