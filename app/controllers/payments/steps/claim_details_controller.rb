module Payments
  module Steps
    class ClaimDetailsController < BaseController
      def edit
        @form_object = Payments::Steps::ClaimDetailForm.build({}, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::ClaimDetailForm, as: :claim_detail)
      end
    end
  end
end
