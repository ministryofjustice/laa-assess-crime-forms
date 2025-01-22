module Nsm
  class ChangeRisksController < Nsm::BaseController
    before_action :check_controller_params

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

    # In normal circumstances this code would never be triggered because ActionController
    #  would error if either of the params weren't present, hence no coverage
    #  but keeping this in here in case threat actors found an exploit
    # :nocov:
    def check_controller_params
      param_model = Nsm::BasicClaimParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
    # :nocov:

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def form_params
      params.require(:nsm_change_risk_form).permit(
        :risk_level, :explanation
      ).merge(current_user:, claim:)
    end
  end
end
