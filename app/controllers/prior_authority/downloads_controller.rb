module PriorAuthority
  class DownloadsController < BaseController
    before_action :check_controller_params

    include FileRedirectable

    def show
      authorize(PriorAuthorityApplication, :show?)
      redirect_to_file_download(params[:id], params[:file_name])
    end

    private

    def controller_params
      params.permit(:id, :file_name)
    end

    def check_controller_params
      param_model = PriorAuthority::DownloadsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
