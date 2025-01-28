module Nsm
  class MakeDecisionsController < Nsm::BaseController
    def edit
      authorize(claim)
      decision = MakeDecisionForm.new(claim:, **claim.data.slice(*MakeDecisionForm.attribute_names))
      render locals: { claim:, decision: }
    end

    def update
      authorize(claim)
      decision = MakeDecisionForm.new(claim:, **form_params)
      if controller_params[:save_and_exit]
        decision.stash
        redirect_to your_nsm_claims_path
      elsif decision.save
        redirect_to closed_nsm_claims_path, flash: { success: success_notice(decision) }
      else
        render :edit, locals: { claim:, decision: }
      end
    end

    private

    def success_notice(decision)
      reference = BaseViewModel.build(:laa_reference, claim)
      t(".decision.#{decision.state}",
        ref: reference.laa_reference, url: nsm_claim_claim_details_path(claim.id))
    end

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def form_params
      params.require(:nsm_make_decision_form).permit(
        :state, :grant_comment, :partial_comment, :reject_comment
      ).merge(current_user:)
    end

    def controller_params
      params.permit(:claim_id, :save_and_exit)
    end

    def check_controller_params
      param_model = Nsm::BasicDecisionParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
