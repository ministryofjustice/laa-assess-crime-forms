module Nsm
  class AssignmentsController < Nsm::BaseController
    before_action :check_controller_params

    include AssignmentConcern

    def new
      authorize claim, :self_assign?
      @form = AssignmentForm.new
    end

    def create
      authorize(claim, :self_assign?)
      @form = AssignmentForm.new(form_params)
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:nsm_assignment_form).permit(:comment)
    end

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def process_assignment(comment)
      assign(claim, comment:)
      redirect_to nsm_claim_claim_details_path(claim)
    end

    def controller_params
      params.require(:claim_id)
    end

    def check_controller_params
      param_model = Nsm::AssignmentsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
