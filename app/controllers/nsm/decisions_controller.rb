module Nsm
  class DecisionsController < Nsm::BaseController
    def show
      authorize(claim)
      @decision = BaseViewModel.build(:decision, claim)
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def controller_params
      params.permit(:claim_id, :save_and_exit)
    end

    def param_validator
      @param_validator ||= Nsm::BasicDecisionParams.new(controller_params)
    end
  end
end
