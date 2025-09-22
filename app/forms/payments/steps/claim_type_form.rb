module Payments
  module Steps
    class ClaimTypeForm < BasePaymentsForm
      attribute :claim_type, :string
      validates :claim_type, presence: true, inclusion: { in: %w[non_standard_mag
                                                                 non_standard_mag_supplemental
                                                                 non_standard_mag_appeal
                                                                 non_standard_mag_amendment
                                                                 assigned_counsel
                                                                 assigned_counsel_appeal
                                                                 assigned_counsel_amendment] }
    end
  end
end
