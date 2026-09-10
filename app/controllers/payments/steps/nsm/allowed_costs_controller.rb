module Payments
  module Steps
    module Nsm
      class AllowedCostsController < BaseController
        def edit
          @to_be_paid = multi_step_form_session.calculation_method == LaaCrimeFormsCommon::PaymentBasis::ENTERED_TO_BE_PAID
          @form_object = Payments::Steps::Nsm::AllowedCostsForm.build(multi_step_form_session.answers, multi_step_form_session:)
        end

        def update
          update_and_advance(Payments::Steps::Nsm::AllowedCostsForm, as: :nsm_allowed_costs)
        end
      end
    end
  end
end
