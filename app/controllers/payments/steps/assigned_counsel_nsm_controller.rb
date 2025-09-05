module Payments
  module Steps
    class AssignedCounselNsmController < BaseController
      def edit
        @form_object = Payments::AssignedCounselNsmForm.build(current_application)
      end

      def update
        update_and_advance(Payments::AssignedCounselNsmForm, as: :assigned_counsel_nsm)
      end
    end
  end
end
