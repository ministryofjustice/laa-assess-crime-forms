module Nsm
  class DownloadsController < Nsm::BaseController
    before_action :check_controller_params

    include FileRedirectable

    def show
      claim = Claim.load_from_app_store(controller_params[:claim_id])
      authorize claim
      supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')
      item = supporting_evidence.detect { _1.id == controller_params[:id] }
      redirect_to_file_download(item.file_path, item.file_name)
    end

    private

    def controller_params
      params.permit(:claim_id, :id)
    end

    def check_controller_params
      param_model = Nsm::DownloadsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
