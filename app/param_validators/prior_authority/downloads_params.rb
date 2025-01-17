module PriorAuthority
  class DownloadsParams < BaseParamValidator
    attribute :id, :string
    attribute :file_name, :string

    validates :id, presence: true, is_a_uuid: true
    validates :file_name, presence: true
  end
end
