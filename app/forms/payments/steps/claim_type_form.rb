module Payments
  module Steps
    class ClaimTypeForm < BasePaymentsForm
      attribute :claim_type, :string

      validates :claim_type, inclusion: { in: %w[non_standard_mags
                                                 nsm_supplemental
                                                 nsm_appeal
                                                 nsm_amendment
                                                 assigned_counsel
                                                 ac_appeal
                                                 ac_amendment] }
    end
  end
end
