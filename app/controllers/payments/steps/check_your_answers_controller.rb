module Payments
  module Steps
    class CheckYourAnswersController < BaseController
      def edit
        @form_object = Payments::Steps::CheckYourAnswersForm.build(multi_step_form_session.answers,
                                                                   multi_step_form_session:)
        @claim_details = Payments::ClaimDetailsSummary.new(multi_step_form_session.answers)
        @cost_summary = Payments::CostsSummary.new(multi_step_form_session.answers)
      end
    end
  end
end
