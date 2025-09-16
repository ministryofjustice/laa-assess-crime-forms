module Payments
  module Steps
    class CheckYourAnswersController < BaseController
      def show
        @claim_details = Payments::ClaimDetailsSummary.new(multi_step_form_session.answers)
      end
    end
  end
end
