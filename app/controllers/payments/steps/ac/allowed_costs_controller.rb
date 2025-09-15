module Payments
  module Steps
    module Ac
      class AllowedCostsController < BaseController
        def edit
          @form_object = Payments::Steps::Ac::AllowedCostsForm.new(multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Ac::AllowedCostsForm, as: :ac_allowed_costs)
        end
      end
    end
  end
end
