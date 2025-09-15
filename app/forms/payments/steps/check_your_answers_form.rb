module Payments
  module Steps
    class CheckYourAnswersForm < BasePaymentsForm
      def save
        return false unless valid?

        true
      rescue StandardError
        errors.add(:base, :sync_error)
        false
      end
    end
  end
end
