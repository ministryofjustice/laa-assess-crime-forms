module Payments
  module Steps
    class OfficeCodeSearchController < BaseController
      def edit
        store_return_to_from_params
        @form_object = Payments::Steps::OfficeCodeSearchForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::OfficeCodeSearchForm, as: :office_code_search)
      end
    end
  end
end
