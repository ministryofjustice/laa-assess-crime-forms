module Payments
  module Steps
    class DateReceivedForm < BasePaymentsForm
      attribute :date_received, :date

      validates :date_received,
                presence: true, multiparam_date: { allow_past: true, allow_future: false }
    end
  end
end
