module Payments
  module Steps
    class LaaReferenceForm < BasePaymentsForm
      attribute :laa_reference, :string

      def save
        return false unless valid?

        multi_step_form_session[:laa_reference] = laa_reference

        true
      rescue StandardError
        errors.add(:base, :sync_error)
        false
      end
    end
  end
end
