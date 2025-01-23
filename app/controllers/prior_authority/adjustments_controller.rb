module PriorAuthority
  class AdjustmentsController < PriorAuthority::BaseController
    before_action :check_controller_params

    def index
      application = PriorAuthorityApplication.load_from_app_store(params[:application_id])
      authorize(application, :show?)
      application_summary = BaseViewModel.build(:application_summary, application)
      service_cost = BaseViewModel.build(:service_cost, application)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, application)
      editable = policy(application).update?

      @key_information = BaseViewModel.build(:key_information, application)
      render locals: { application:, application_summary:, service_cost:, core_cost_summary:, editable: }
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
