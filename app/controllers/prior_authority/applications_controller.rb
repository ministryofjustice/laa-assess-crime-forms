module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    before_action :set_default_table_sort_options, only: %i[your open closed]
    before_action :authorize_list, only: %i[your open closed]

    def your
      return redirect_to open_prior_authority_applications_path unless policy(PriorAuthorityApplication).assign?

      model = PriorAuthority::V1::YourApplications.new(params.permit(:page, :sort_by, :sort_direction).merge(current_user:))
      model.execute
      @pagy = model.pagy
      @applications = model.results
    end

    def open
      model = PriorAuthority::V1::OpenApplications.new(params.permit(:page, :sort_by, :sort_direction))
      model.execute
      @pagy = model.pagy
      @applications = model.results
    end

    def closed
      model = PriorAuthority::V1::ClosedApplications.new(params.permit(:page, :sort_by, :sort_direction))
      model.execute
      @pagy = model.pagy
      @applications = model.results
    end

    def show
      application = PriorAuthorityApplication.load_from_app_store(controller_params[:id])
      authorize(application)
      @summary = BaseViewModel.build(:application_summary, application)
      @details = BaseViewModel.build(:application_details, application)
    end

    private

    def controller_params
      params.permit(
        :id,
        :sort_by,
        :sort_direction,
        :page
      )
    end

    def param_validator
      @param_validator ||= PriorAuthority::ApplicationsParams.new(controller_params)
    end

    def set_default_table_sort_options
      default = 'date_updated'
      @sort_by = controller_params.fetch(:sort_by, default)
      @sort_direction = controller_params.fetch(:sort_direction, 'descending')
    end

    def submission_id
      controller_params[:id]
    end

    # :nocov:
    def secondary_id
      nil
    end
    # :nocov:

    def authorize_list
      authorize PriorAuthorityApplication, :index?
    end
  end
end
