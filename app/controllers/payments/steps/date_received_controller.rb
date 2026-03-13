module Payments
  module Steps
    class DateReceivedController < BaseController
      def edit
        @form_object = Payments::Steps::DateReceivedForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        return if update_with_return_to_cya(
          Payments::Steps::DateReceivedForm,
          as: :date_received,
          success_redirect: :check_your_answers
        )

        update_and_advance(Payments::Steps::DateReceivedForm, as: :date_received)
      end
    end
  end
end
