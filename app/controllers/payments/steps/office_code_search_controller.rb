module Payments
  module Steps
    class OfficeCodeSearchController < BaseController
      before_action :clear_session_payment, only: [:edit], if: -> { params[:new_record].present? }

      def edit
        @form_object = Payments::Steps::OfficeCodeSearchForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::OfficeCodeSearchForm, as: :office_code_search)
      end

      private

      def clear_session_payment
        request_type = multi_step_form_session['request_type']
        multi_step_form_session.reset_answers
        multi_step_form_session['request_type'] = request_type
      end
    end
  end
end
