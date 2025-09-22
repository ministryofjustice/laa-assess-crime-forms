module Payments
  module Steps
    class ClaimTypesController < BaseController
      def edit
        @form_object = Payments::Steps::ClaimTypeForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::ClaimTypeForm, as: :claim_type)
      end
    end
  end
end
