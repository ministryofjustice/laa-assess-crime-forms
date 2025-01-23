module Nsm
  class FurtherInformationDownloadsParams < BaseParamValidator
    attribute :id, :string
    attribute :file_name, :string

    validates :id, presence: true
    validates :file_name, presence: true
  end
end
