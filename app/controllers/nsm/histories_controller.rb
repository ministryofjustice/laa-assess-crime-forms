module Nsm
  class HistoriesController < Nsm::BaseController
    before_action :check_controller_params

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
      params.require(:nsm_claim_note_form).permit(
        :note
      ).merge(current_user:, claim:)
    end

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
  end
end
