module Payments
  module Steps
    module Nsm
      class ClaimedCostsController < BaseController
        def edit
          @form_object = Payments::Steps::Nsm::ClaimedCostsForm.new(multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Nsm::ClaimedCostsForm, as: :nsm_claimed_costs)
        end
      end
    end
  end
end
