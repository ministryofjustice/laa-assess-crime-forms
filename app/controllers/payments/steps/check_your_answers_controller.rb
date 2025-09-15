module Payments
  module Steps
    class CheckYourAnswersController < BaseController
      def show
        @form_object = Payments::Steps::CheckYourAnswersForm.new(multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::CheckYourAnswersForm, as: :check_your_answers)
      end
    end
  end
end
