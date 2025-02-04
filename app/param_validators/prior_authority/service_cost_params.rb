module PriorAuthority
  class ServiceCostParams < BaseParamValidator
    attribute :id, :string
    attribute :application_id, :string
    attribute :save_and_exit, :boolean

    validates :application_id, presence: true, is_a_uuid: true
    validates :id, presence: true, is_a_uuid: true
  end
end
