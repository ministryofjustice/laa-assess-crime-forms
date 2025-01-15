module Nsm
  class SupportingEvidencesController < Nsm::BaseController
    before_action :check_controller_params

    # 15 min expiry on pre-signed urls to keep evidence download as secure as possible
    PRESIGNED_EXPIRY = 900

    def show
      claim = Claim.load_from_app_store(params[:claim_id])
      authorize(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')
      @pagy, @supporting_evidence = pagy_array(supporting_evidence)
      render locals: { claim:, claim_summary: }
    end

    private

    def controller_params
      params.permit(:claim_id)
    end

    def check_controller_params
      param_model = Nsm::BasicClaimParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
