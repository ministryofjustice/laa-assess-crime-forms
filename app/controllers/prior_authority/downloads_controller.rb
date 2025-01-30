module PriorAuthority
  class DownloadsController < BaseController
    include FileRedirectable

    def show
      authorize(PriorAuthorityApplication, :show?)
      redirect_to_file_download(controller_params[:id], controller_params[:file_name])
    end

    private

    def controller_params
      params.permit(:id, :file_name)
    end

    def param_validator
      PriorAuthority::DownloadsParams.new(controller_params)
    end
  end
end
