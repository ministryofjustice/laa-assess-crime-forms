module PriorAuthority
  class NotesController < PriorAuthority::BaseController
    def new
      authorize(submission, :edit?)
      @form_object = NoteForm.new(submission:)
    end

    def create
      authorize(submission, :update?)
      @form_object = NoteForm.new(form_params)
      if @form_object.save
        redirect_to prior_authority_application_events_path(submission)
      else
        render :new
      end
    end

    private

    def form_params
      params.require(:prior_authority_note_form).permit(
        *NoteForm.attribute_names
      ).merge(
        current_user:,
        submission:,
      )
    end

    def submission
      @submission ||= PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
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
