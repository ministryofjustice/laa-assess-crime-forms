module Payments
  module Steps
    module Ac
      class ClaimedCostsController < BaseController
        def edit
          @form_object = Payments::Steps::Ac::ClaimedCostsForm.new(multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Ac::ClaimedCostsForm, as: :ac_claimed_costs)
        end
      end
    end
  end
end
