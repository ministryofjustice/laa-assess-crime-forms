module Nsm
  class FurtherInformationDownloadsController < Nsm::BaseController
    before_action :check_controller_params

    include FileRedirectable

    def show
      authorize Claim, :show?
      redirect_to_file_download(controller_params[:id], controller_params[:file_name])
    end

    private

    def controller_params
      params.permit(:id, :file_name)
    end

    # In normal circumstances this code would never be triggered because ActionController
    #  would error if either of the params weren't present, hence no coverage
    #  but keeping this in here in case threat actors found an exploit
    # :nocov:
    def check_controller_params
      param_model = Nsm::FurtherInformationDownloadsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
    # :nocov:
  end
end
