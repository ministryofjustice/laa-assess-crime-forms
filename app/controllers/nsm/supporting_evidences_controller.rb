module Nsm
  class SupportingEvidencesController < Nsm::BaseController
    # 15 min expiry on pre-signed urls to keep evidence download as secure as possible
    PRESIGNED_EXPIRY = 900
    ITEM_COUNT_OVERRIDE = 20

    def show
      claim = Claim.load_from_app_store(controller_params[:claim_id])
      authorize(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')
      @pagy, @supporting_evidence = pagy_array(supporting_evidence, limit: ITEM_COUNT_OVERRIDE)
      render locals: { claim:, claim_summary: }
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
