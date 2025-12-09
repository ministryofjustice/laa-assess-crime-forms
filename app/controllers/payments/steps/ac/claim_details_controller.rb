module Payments
  module Steps
    module Ac
      class ClaimDetailsController < BaseController
        def edit
          @request_type = multi_step_form_session.answers['request_type']
          @form_object = Payments::Steps::Ac::ClaimDetailForm.build(multi_step_form_session.answers, multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Ac::ClaimDetailForm, as: :ac_claim_details)
        end
      end
    end
  end
end
