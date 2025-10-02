# :nocov:
module Payments
  module Steps
    module Ac
      class NsmCheckController < BaseController
        def edit
          @form_object = Payments::Steps::Ac::NsmCheckForm.build(multi_step_form_session.answers, multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Ac::NsmCheckForm, as: :nsm_check)
        end
      end
    end
  end
end
# :nocov:
