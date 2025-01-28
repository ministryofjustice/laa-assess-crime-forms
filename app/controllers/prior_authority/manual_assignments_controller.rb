module PriorAuthority
  class ManualAssignmentsController < PriorAuthority::AssignmentsController
    def new
      authorize(application, :assign?)
      @form = ManualAssignmentForm.new
    end

    def create
      authorize(application, :assign?)
      @form = ManualAssignmentForm.new(params.require(:prior_authority_manual_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def process_assignment(comment)
      if application.assigned_user_id.nil?
        assign_and_redirect(application, comment)
      else
        redirect_to prior_authority_application_path(application), flash: { notice: t('.already_assigned') }
      end
    end

    def application
      @application ||= PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
    end

    def controller_params
      params.permit(:application_id)
    end

    # In normal circumstances this code would never be triggered because ActionController
    #  would error if either of the params weren't present, hence no coverage
    #  but keeping this in here in case threat actors found an exploit
    # :nocov:
    def check_controller_params
      param_model = PriorAuthority::BasicApplicationParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
    # :nocov:
  end
end
