module Nsm
  class MakeDecisionsController < Nsm::BaseController
    def edit
      authorize(claim)
      decision = MakeDecisionForm.new(claim:, **claim.data.slice(*MakeDecisionForm.attribute_names))
      render locals: { claim:, decision: }
    end

    def update
      authorize(claim)
      decision = MakeDecisionForm.new(claim:, **decision_params)
      if params['save_and_exit']
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
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def decision_params
      params.require(:nsm_make_decision_form).permit(
        :state, :grant_comment, :partial_comment, :reject_comment
      ).merge(current_user:)
    end
  end
end
