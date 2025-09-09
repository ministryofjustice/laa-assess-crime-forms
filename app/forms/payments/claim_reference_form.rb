module Payments
  class ClaimReferenceForm < BaseForm
    include LaaCrimeFormsCommon::Validators

    attribute :claim_reference, :string
    validates :claim_reference, presence: true
  end
end
