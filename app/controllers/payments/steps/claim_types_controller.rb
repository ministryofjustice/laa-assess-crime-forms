module Payments
  module Steps
    class ClaimTypesController < BaseController
      def edit
        @form_object = Payments::ClaimTypeForm.build(current_application)
      end

      def update
        update_and_advance(Payments::ClaimTypeForm, as: :claim_type)
      end
    end
  end
end
