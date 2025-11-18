module Nsm
  class MakeDecisionsController < Nsm::BaseController
    def edit
      authorize(claim)
      decision = MakeDecisionForm.new(claim:, **claim.data.slice(*MakeDecisionForm.attribute_names))
      render locals: { claim:, decision: }
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize(claim)
      decision = MakeDecisionForm.new(claim:, **form_params)
      if controller_params[:save_and_exit]
        decision.stash
        redirect_to your_nsm_claims_path
      elsif decision.save
        if FeatureFlags.payments.enabled? && decision.state != Claim::REJECTED
          redirect_to nsm_claim_decision_path(claim)
        else
          redirect_to closed_nsm_claims_path, flash: { success: success_notice(decision) }
        end
      else
        render :edit, locals: { claim:, decision: }
      end
    end
    # rubocop:enable Metrics/AbcSize

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
      params.expect(
        nsm_make_decision_form: [:state, :grant_comment, :partial_comment, :reject_comment]
      ).merge(current_user:)
    end

    def controller_params
      params.permit(:claim_id, :save_and_exit)
    end

    def param_validator
      @param_validator ||= Nsm::BasicDecisionParams.new(controller_params)
    end
  end
end
