module Nsm
  class AdjustmentsController < Nsm::BaseController
    before_action :check_controller_params

    def confirm_deletion
      authorize claim, :update?
      form = DeleteAdjustmentsForm.new

      render :confirm_deletion_adjustments, locals: { deletion_path:, form: }
    end

    def delete_all
      authorize claim, :update?
      form = DeleteAdjustmentsForm.new(**form_params)
      deleter = Nsm::AllAdjustmentsDeleter.new(form_params, nil, current_user, claim)

      if form.valid?
        deleter.call!
        redirect_to nsm_claim_claim_details_path, flash: { success: t('.success') }
      else
        render :confirm_deletion_adjustments, locals: { deletion_path:, form: }
      end
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def deletion_path
      delete_all_nsm_claim_adjustments_path(controller_params[:claim_id])
    end

    def form_params
      params.require(:nsm_delete_adjustments_form).permit(:comment)
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
