module Payments
  module Steps
    class DateReceivedController < BaseController
      def edit
        @form_object = Payments::Steps::DateReceivedForm.new(multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::DateReceivedForm, as: :date_received)
      end
    end
  end
end
