module Payments
  module Steps
    class DateReceivedForm < BasePaymentsForm
      attribute :date_received, :string

      def save
        return false unless valid?

        multi_step_form_session[:date_received] = date_received

        true
      rescue StandardError
        errors.add(:base, :sync_error)
        false
      end
    end
  end
end
