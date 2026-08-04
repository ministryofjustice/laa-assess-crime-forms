module Payments
  class EmailPaymentReportMailer < NotifyMailer
    def notify(claim_type, start_date, end_date, recipient)
      message = instantiate_message(claim_type, start_date, end_date)
      set_template(message.template)
      set_personalisation(**message.contents)
      mail(to: recipient)
    end

    private

    def instantiate_message(claim_type, start_date, end_date)
      message_class(claim_type).new(start_date, end_date)
    end

    def message_class(claim_type)
      if claim_type == 'ac'
        Payments::Messages::AcPaymentReport
      elsif claim_type == 'nsm'
        Payments::Messages::NsmPaymentReport
      else
        raise ArgumentError, "Invalid claim type: #{claim_type}"
      end
    end
  end
end
