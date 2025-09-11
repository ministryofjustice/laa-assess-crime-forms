module Payments
  module Steps
    class ClaimDetailForm < BasePaymentsForm
      attribute :ufn, :string
      attribute :multi_step_form_session

      def save
        return false unless valid?

        multi_step_form_session[:ufn] = ufn

        true
      rescue StandardError
        errors.add(:base, :sync_error)
        false
      end
    end
  end
end
