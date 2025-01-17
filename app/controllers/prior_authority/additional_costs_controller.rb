module PriorAuthority
  class AdditionalCostsController < PriorAuthority::BaseController
    before_action :check_controller_params

    def edit
      authorize(submission)
      all_costs = BaseViewModel.build(:additional_cost, submission, 'additional_costs')
      index = all_costs.index do |model|
        model.id == controller_params[:id]
      end

      item = all_costs[index]
      form = AdditionalCostForm.new(submission:, item:, **item.form_attributes)

      render locals: { submission:, item:, form:, index: }
    end

    def update
      authorize(submission)
      all_costs = BaseViewModel.build(:additional_cost, submission, 'additional_costs')
      index = all_costs.index do |model|
        model.id == controller_params[:id]
      end

      item = all_costs[index]

      form = AdditionalCostForm.new(submission:, item:, **form_params)

      if form.save!
        redirect_to prior_authority_application_adjustments_path(submission)
      else
        render :edit, locals: { submission:, item:, form:, index: }
      end
    end

    def confirm_deletion
      authorize(submission, :edit?)
      index = submission.data['additional_costs'].index { _1['id'] == controller_params[:id] }
      render 'prior_authority/shared/confirm_delete_adjustment',
             locals: {
               item_name: t('.additional_cost', n: index + 1),
               deletion_path: prior_authority_application_additional_cost_path(controller_params[:application_id],
                                                                               controller_params[:id])
             }
    end

    def destroy
      authorize(submission, :edit?)
      PriorAuthority::AdjustmentDeleter.new(controller_params, :additional_cost, current_user, submission).call!
      redirect_to prior_authority_application_adjustments_path(controller_params[:application_id])
    end

    private

    def form_params
      params.require(:prior_authority_additional_cost_form).permit(
        :unit_type,
        :items,
        :cost_per_item,
        :period,
        :cost_per_hour,
        :explanation,
      ).merge(
        current_user: current_user,
        id: params[:id]
      )
    end

    def submission
      @submission ||= PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
    end

    def controller_params
      params.permit(:id, :application_id)
    end

    def check_controller_params
      param_model = PriorAuthority::CostsParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
