module Payments
  module Steps
    class OfficeCodeConfirmController < BaseController
      def edit
        @form_object = Payments::Steps::OfficeCodeConfirmForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        if incorrect_office?
          redirect_to edit_payments_steps_office_code_search_path(id: params[:id])
        else
          update_and_advance(Payments::Steps::OfficeCodeConfirmForm, as: :office_code_confirm)
        end
      end

      private

      def incorrect_office?
        params
          .expect(payments_steps_office_code_confirm_form: [:confirm_office_code])
          .fetch(:confirm_office_code) == 'false'
      end
    end
  end
end
