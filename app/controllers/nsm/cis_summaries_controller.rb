module Nsm
  class CisSummariesController < Nsm::BaseController
    def show
      claim = Claim.load_from_app_store(controller_params[:claim_id])
      authorize(claim)
      cis_summary = CisSummary::Table.new(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build('CisSummary::AssessmentCostSummary', claim)
      render locals: { claim:, claim_summary:, cis_summary:, core_cost_summary: }
    end

    private

    def controller_params
      params.permit(:claim_id)
    end

    def param_validator
      @param_validator ||= Nsm::BasicClaimParams.new(controller_params)
    end
  end
end
