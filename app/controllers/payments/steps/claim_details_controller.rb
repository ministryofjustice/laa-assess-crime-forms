module Payments
  module Steps
    class ClaimDetailsController < BaseController
      def edit
        @form_object = Payments::ClaimDetailForm.new(current_application)
      end

      def update
        update_and_advance(Payments::ClaimDetailForm, as: :claim_detail)
      end
    end
  end
end
