module Nsm
  class UnassignmentsController < Nsm::BaseController
    before_action :check_controller_params
    before_action :check_claim_assigned

    def edit
      authorize(claim, :unassign?)
      unassignment = UnassignmentForm.new(claim:, current_user:)
      render locals: { claim:, unassignment: }
    end

    def update
      authorize(claim, :unassign?)
      unassignment = UnassignmentForm.new(claim:, **send_back_params)
      if unassignment.save
        redirect_to nsm_claim_claim_details_path(claim)
      else
        render :edit, locals: { claim:, unassignment: }
      end
    end

    private

    def check_claim_assigned
      return if claim.assigned_user_id.present?

      redirect_to nsm_claim_claim_details_path(claim), flash: { notice: t('nsm.unassignments.already_unassigned') }
    end

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def send_back_params
      params.require(:nsm_unassignment_form).permit(
        :comment
      ).merge(current_user:)
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
