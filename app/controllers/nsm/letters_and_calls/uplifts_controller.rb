module Nsm
  module LettersAndCalls
    class UpliftsController < Nsm::BaseController
      before_action :check_controller_params
      def edit
        authorize(claim)
        form = Uplift::LettersAndCallsForm.new(claim:)

        render locals: { claim:, form: }
      end

      def update
        authorize(claim)
        form = Uplift::LettersAndCallsForm.new(claim:, **form_params)

        if form.save!
          redirect_to nsm_claim_letters_and_calls_path(claim),
                      flash: { success: t('.uplift_removed') }
        else
          render :edit, locals: { claim:, form: }
        end
      end

      private

      def claim
        @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
      end

      def form_params
        params.require(:nsm_uplift_letters_and_calls_form)
              .permit(:explanation)
              .merge(current_user:)
      end

      def controller_params
        params.permit(:claim_id)
      end

      def check_controller_params
        param_model = Nsm::BasicClaimParams.new(controller_params)
        raise param_model.error_summary.to_s unless param_model.valid?
      end
    end
  end
end
