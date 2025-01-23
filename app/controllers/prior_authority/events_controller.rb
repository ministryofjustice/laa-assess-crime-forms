module PriorAuthority
  class EventsController < PriorAuthority::BaseController
    before_action :check_controller_params

    def index
      application = PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
      authorize(application, :show?)
      application_summary = BaseViewModel.build(:application_summary, application)
      editable = policy(application).update?

      pagy, records = pagy_array(application.events.sort_by(&:created_at).reverse)
      events = records.map { V1::EventSummary.new(event: _1) }

      render locals: { application_summary:, editable:, pagy:, events: }
    end

    private

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
