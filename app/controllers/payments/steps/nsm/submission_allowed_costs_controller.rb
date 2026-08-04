module Payments
  module Steps
    module Nsm
      class SubmissionAllowedCostsController < BaseController
        def edit
          @form_object = Payments::Steps::Nsm::SubmissionAllowedCostsForm.build(multi_step_form_session.answers,
                                                                                multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Nsm::SubmissionAllowedCostsForm, as: :submission_allowed_costs)
        end
      end
    end
  end
end
