module Payments
  module Steps
    class DateClaimAssessedForm < BasePaymentsForm
      attribute :date_claim_assessed, :date

      validates :date_claim_assessed,
                presence: true, multiparam_date: { allow_past: true, allow_future: false }
    end
  end
end
