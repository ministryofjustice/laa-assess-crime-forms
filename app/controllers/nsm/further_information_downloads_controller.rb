module Nsm
  class FurtherInformationDownloadsController < Nsm::BaseController
    include FileRedirectable

    def show
      authorize Claim, :show?
      redirect_to_file_download(controller_params[:id], controller_params[:file_name])
    end

    private

    def controller_params
      params.permit(:id, :file_name)
    end

    def param_validator
      @param_validator ||= Nsm::FurtherInformationDownloadsParams.new(controller_params)
    end
  end
end
