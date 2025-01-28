module PriorAuthority
  class RelatedApplicationsController < PriorAuthority::BaseController
    before_action :set_default_table_sort_options, only: %i[index]

    def index
      application = PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
      authorize(application, :show?)
      application_summary = BaseViewModel.build(:application_summary, application)
      editable = policy(application).update?

      model = PriorAuthority::V1::RelatedApplications.new(
        params.permit(:page, :sort_by, :sort_direction).merge(current_application_summary: application_summary)
      )
      model.execute
      @pagy = model.pagy
      @applications = model.results

      render locals: { application:, application_summary:, editable: }
    end

    private

    def set_default_table_sort_options
      @sort_by = controller_params.fetch(:sort_by, 'date_updated')
      @sort_direction = controller_params.fetch(:sort_direction, 'descending')
    end

    def controller_params
      params.permit(:application_id, :sort_by, :sort_direction)
    end

    def check_controller_params
      param_model = PriorAuthority::RelatedApplicationsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
