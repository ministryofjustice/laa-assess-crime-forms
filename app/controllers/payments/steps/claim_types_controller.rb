module Payments
  module Steps
    class ClaimTypesController < BaseController
      def edit
        @form_object = Payments::Steps::ClaimTypeForm.new
      end

      def update
        update_and_advance(Payments::Steps::ClaimTypeForm, as: :claim_type)
      end

      private

      def current_application
        @current_application ||= Decisions::FormSession.new(process: 'Payments',
                                                            session: session, session_id: params[:id])
      end
    end
  end
end
