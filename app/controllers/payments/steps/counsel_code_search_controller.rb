module Payments
  module Steps
    class CounselCodeSearchController < BaseController
      def edit
        @form_object = Payments::Steps::CounselCodeSearchForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::CounselCodeSearchForm, as: :counsel_code_search)
      end
    end
  end
end
