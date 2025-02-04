module PriorAuthority
  class AdjustmentsController < PriorAuthority::BaseController
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

    def param_validator
      @param_validator ||= PriorAuthority::BasicApplicationParams.new(controller_params)
    end
  end
end
