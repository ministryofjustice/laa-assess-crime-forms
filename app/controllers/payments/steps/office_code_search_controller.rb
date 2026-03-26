module Payments
  module Steps
    class OfficeCodeSearchController < BaseController
      def edit
        multi_step_form_session.mark_return_to_cya! if params[:return_to_cya].present?
        @form_object = Payments::Steps::OfficeCodeSearchForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::OfficeCodeSearchForm, as: :office_code_search)
      end
    end
  end
end
