# frozen_string_literal: true

module Payments
  class EmailToFinanceMailer < NotifyMailer
    def notify(start_date, end_date)
      message = instantiate_message(start_date, end_date)
      set_template(message.template)
      tmpfile = construct_file(start_date, end_date)
      set_personalisation(**message.contents(tmpfile))
      mail(to: message.recipient)
      tmpfile.unlink
    end

    private

    def instantiate_message(start_date, end_date)
      Payments::Messages::FinanceReport.new(start_date, end_date)
    end

    def construct_file(start_date, end_date)
      file = Tempfile.new(['finance_report', '.csv'], binmode: true)
      file.write(MetabaseApiClient.new.download_question(278, start_date, end_date))
      file.close
      file
    end
  end
end
