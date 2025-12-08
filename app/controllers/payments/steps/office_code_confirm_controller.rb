module Payments
  module Steps
    class OfficeCodeConfirmController < BaseController
      def edit
        @form_object = Payments::Steps::OfficeCodeConfirmForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::OfficeCodeConfirmForm, as: :office_code_confirm)
      end
    end
  end
end
