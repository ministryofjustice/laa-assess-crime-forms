module Payments
  module Steps
    class ClaimTypeForm < BasePaymentsForm
      attribute :claim_type, :string
      attribute :multi_step_form_session

      validates :claim_type, inclusion: { in: %w[non_standard_mags assigned_counsel] }

      def save
        return false unless valid?

        multi_step_form_session[:claim_type] = claim_type

        true
      rescue StandardError
        errors.add(:base, :sync_error)
        false
      end
    end
  end
end
