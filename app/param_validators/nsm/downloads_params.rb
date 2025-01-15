module Nsm
  class DownloadsParams < BaseParamValidator
    attribute :claim_id, :string
    attribute :id, :string

    validates :claim_id, presence: true
    validates :id, presence: true
  end
end
