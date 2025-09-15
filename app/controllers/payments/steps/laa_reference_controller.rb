module Payments
  module Steps
    class LaaReferenceController < BaseController
      def edit
        @form_object = Payments::Steps::LaaReferenceForm.new(multi_step_form_session:)
      end

      def update
        update_and_advance(Payments::Steps::LaaReferenceForm, as: :laa_reference)
      end
    end
  end
end
