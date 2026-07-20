# frozen_string_literal: true

module Payments
  class EmailToFinanceMailer < NotifyMailer
    def notify(start_date, end_date)
      message = instantiate_message(start_date, end_date)
      set_template(message.template)
      set_personalisation(**message.contents)
      mail(to: message.recipient)
    end

    private

    def instantiate_message(start_date, end_date)
      Payments::Messages::FinanceReport.new(start_date, end_date)
    end
  end
end
