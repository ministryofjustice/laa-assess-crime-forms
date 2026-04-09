module Payments
  module Steps
    class DateClaimAssessedController < BaseController
      def edit
        @form_object = Payments::Steps::DateClaimAssessedForm.build(multi_step_form_session.answers, multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::DateClaimAssessedForm, as: :date_claim_assessed)
      end
    end
  end
end
