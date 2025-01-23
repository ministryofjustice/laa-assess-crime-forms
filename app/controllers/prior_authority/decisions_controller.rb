module PriorAuthority
  class DecisionsController < PriorAuthority::BaseController
    before_action :check_controller_params

    def show
      authorize(submission)
      @summary = BaseViewModel.build(:application_summary, submission)
      @decision = BaseViewModel.build(:decision, submission)
    end

    def new
      authorize(submission, :edit?)
      @form_object = DecisionForm.new(submission:,
                                      **submission.data.slice(*DecisionForm.attribute_names))
    end

    def create
      authorize(submission, :update?)
      @form_object = DecisionForm.new(form_params)
      if controller_params[:save_and_exit]
        @form_object.stash
        redirect_to your_prior_authority_applications_path
      elsif @form_object.save
        redirect_to prior_authority_application_decision_path(submission)
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:prior_authority_decision_form).permit(
        *DecisionForm.attribute_names
      ).merge(
        current_user:,
        submission:,
      )
    end

    def submission
      @submission ||= PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
    end

    def controller_params
      params.permit(:application_id, :save_and_exit)
    end

    # In normal circumstances this code would never be triggered because ActionController
    #  would error if either of the params weren't present, hence no coverage
    #  but keeping this in here in case threat actors found an exploit
    # :nocov:
    def check_controller_params
      param_model = PriorAuthority::DecisionsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
    # :nocov:
  end
end
