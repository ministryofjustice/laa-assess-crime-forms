module Payments
  module Steps
    module Nsm
      class ClaimDetailsController < BaseController
        def edit
          @form_object = Payments::Steps::Nsm::ClaimDetailForm.build(multi_step_form_session.answers, multi_step_form_session:)
        end

        def update
          return if update_with_return_to_cya(
            Payments::Steps::Nsm::ClaimDetailForm,
            as: :nsm_claim_details,
            success_redirect: :check_your_answers
          )

          update_and_advance(Payments::Steps::Nsm::ClaimDetailForm, as: :nsm_claim_details)
        end
      end
    end
  end
end
