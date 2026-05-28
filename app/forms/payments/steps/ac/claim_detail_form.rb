module Payments
  module Steps
    module Ac
      class ClaimDetailForm < BasePaymentsForm
        attribute :date_claim_assessed, :date
        attribute :ufn, :string
        attribute :defendant_last_name, :string

        validates :ufn, presence: true, ufn: true
        validates :date_claim_assessed,
                  presence: true, multiparam_date: { allow_past: true, allow_future: false }
        validates :defendant_last_name, presence: true
      end
    end
  end
end
