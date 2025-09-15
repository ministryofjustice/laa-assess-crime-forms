module Payments
  module Steps
    module Nsm
      class ClaimDetailsController < BaseController
        def edit
          @form_object = Payments::Steps::Nsm::ClaimDetailForm.new(multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Nsm::ClaimDetailForm, as: :nsm_claim_details)
        end
      end
    end
  end
end
