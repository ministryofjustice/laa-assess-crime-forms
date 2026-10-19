module PriorAuthority
  class AdjustmentsController < PriorAuthority::BaseController
    def index
      application = PriorAuthorityApplication.load_from_app_store(params[:application_id])
      authorize(application, :show?)
      application_summary = BaseViewModel.build(:application_summary, application)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, application)
      editable = policy(application).update?

      @details = BaseViewModel.build(:application_details, application)
      @key_information = BaseViewModel.build(:key_information, application)
      render locals: { application:, application_summary:, core_cost_summary:, editable: }
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
