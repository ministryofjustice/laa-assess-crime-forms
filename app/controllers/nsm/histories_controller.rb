module Nsm
  class HistoriesController < Nsm::BaseController
    def show
      authorize(claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      pagy, history_events = pagy_array(claim.events.sort_by(&:created_at).reverse)
      claim_note = ClaimNoteForm.new(claim:)

      render locals: { claim:, claim_summary:, history_events:, claim_note:, pagy: }
    end

    def create
      authorize(claim, :edit?)
      claim_note = ClaimNoteForm.new(form_params)
      if claim_note.save
        redirect_to nsm_claim_history_path(claim)
      else
        claim_summary = BaseViewModel.build(:claim_summary, claim)
        pagy, history_events = pagy_array(claim.events.sort_by(&:created_at).reverse)

        render :show, locals: { claim:, claim_summary:, history_events:, claim_note:, pagy: }
      end
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def form_params
      params.expect(
        nsm_claim_note_form: [:note]
      ).merge(current_user:, claim:)
    end

    def controller_params
      params.permit(:claim_id)
    end

    def param_validator
      @param_validator ||= Nsm::BasicClaimParams.new(controller_params)
    end
  end
end
