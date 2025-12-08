module Payments
  module Steps
    class DateReceivedController < BaseController
      def edit
        @request_type = multi_step_form_session.answers['request_type']
        @form_object = Payments::Steps::DateReceivedForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::DateReceivedForm, as: :date_received)
      end
    end
  end
end
