module Nsm
  class ChangeRisksController < Nsm::BaseController
    def edit
      authorize(claim)
      risk = ChangeRiskForm.new(claim: claim, risk_level: claim.risk)
      render locals: { claim:, risk: }
    end

    def update
      authorize(claim)
      risk = ChangeRiskForm.new(form_params)

      if risk.save
        redirect_to nsm_claim_claim_details_path(controller_params[:claim_id]),
                    flash: { success: t('.success', level: risk.risk_level) }
      else
        render :edit, locals: { claim:, risk: }
      end
    end

    private

    def controller_params
      params.permit(:claim_id)
    end

    def param_validator
      @param_validator ||= Nsm::BasicClaimParams.new(controller_params)
    end

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def form_params
      params.expect(
        nsm_change_risk_form: [:risk_level, :explanation]
      ).merge(current_user:, claim:)
    end
  end
end
