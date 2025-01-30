module Nsm
  class ClaimDetailsController < Nsm::BaseController
    def show
      authorize(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      claim_details = ClaimDetails::Table.new(claim)

      render locals: { claim:, claim_summary:, claim_details:, provider_updates: }
    end

    private

    def controller_params
      params.permit(:claim_id)
    end

    def param_validator
      Nsm::BasicClaimParams.new(controller_params)
    end

    def provider_updates
      return nil if claim.data['further_information'].blank?

      BaseViewModel.build(:further_information, claim, 'further_information').sort_by(&:requested_at).reverse
    end

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end
  end
end
