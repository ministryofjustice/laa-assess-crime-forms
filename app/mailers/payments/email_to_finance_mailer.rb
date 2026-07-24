# frozen_string_literal: true

module Payments
  class EmailToFinanceMailer < NotifyMailer
    def notify(start_date, end_date)
      message = instantiate_message(start_date, end_date)
      set_template(message.template)
      file = Tempfile.new(['finance_report', '.csv'])
      file.write(MetabaseApiClient.new.download_question(278, @start_date, @end_date))
      file.close
      set_personalisation(**message.contents(file))
      mail(to: message.recipient)
      file.unlink
    end

    private

    def instantiate_message(start_date, end_date)
      Payments::Messages::FinanceReport.new(start_date, end_date)
    end
  end
end
