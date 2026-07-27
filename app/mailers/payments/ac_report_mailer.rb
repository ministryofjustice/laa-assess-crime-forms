# frozen_string_literal: true

module Payments
  class AcReportMailer < NotifyMailer
    def notify(start_date, end_date, recipient)
      message = instantiate_message(start_date, end_date)
      set_template(message.template)
      set_personalisation(**message.contents)
      mail(to: recipient)
    end

    private

    def instantiate_message(start_date, end_date)
      Payments::Messages::AcPaymentReport.new(start_date, end_date)
    end
  end
end
