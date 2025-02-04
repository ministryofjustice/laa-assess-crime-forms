module Nsm
  class DownloadsParams < BaseParamValidator
    attribute :claim_id, :string
    attribute :id, :string

    validates :claim_id, presence: true, is_a_uuid: true
    validates :id, presence: true
  end
end
