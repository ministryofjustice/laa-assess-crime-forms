module Payments
  module Steps
    module Nsm
      class LaaReferenceCheckController < BaseController
        def edit
          @form_object = Payments::Steps::Nsm::LaaReferenceCheckForm.new(multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Nsm::LaaReferenceCheckForm, as: :laa_reference_check)
        end
      end
    end
  end
end
