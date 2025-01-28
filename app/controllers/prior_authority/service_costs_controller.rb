module PriorAuthority
  class ServiceCostsController < PriorAuthority::BaseController
    def edit
      authorize(submission, :edit?)
      all_service_costs = BaseViewModel.build(:service_cost, submission, 'quotes')

      item = all_service_costs.find do |model|
        model.id == controller_params[:id]
      end

      form = ServiceCostForm.new(submission:, item:, **item.form_attributes)

      render locals: { submission:, item:, form: }
    end

    def update
      authorize(submission, :update?)
      all_service_costs = BaseViewModel.build(:service_cost, submission, 'quotes')

      item = all_service_costs.find do |model|
        model.id == controller_params[:id]
      end

      form = ServiceCostForm.new(submission:, item:, **form_params(item))

      if form.save!
        redirect_to prior_authority_application_adjustments_path(submission)
      else
        render :edit, locals: { submission:, item:, form: }
      end
    end

    def confirm_deletion
      authorize(submission, :edit?)
      service_type = t(submission.data['service_type'], scope: 'prior_authority.service_types')
      render 'prior_authority/shared/confirm_delete_adjustment',
             locals: { item_name: t('.service_type_cost', service_type:),
                       deletion_path: prior_authority_application_service_cost_path(submission, controller_params[:id]) }
    end

    def destroy
      authorize(submission, :update?)
      deleter = PriorAuthority::AdjustmentDeleter.new(controller_params, :service_cost, current_user, submission)
      deleter.call!
      redirect_to prior_authority_application_adjustments_path(controller_params[:application_id])
    end

    private

    def submission
      @submission ||= PriorAuthorityApplication.load_from_app_store(controller_params[:application_id])
    end

    def form_params(item)
      params.require(:prior_authority_service_cost_form).permit(
        :cost_type,
        :period,
        :cost_per_hour,
        :items,
        :item_type,
        :cost_per_item,
        :explanation,
      ).merge(
        current_user: current_user,
        cost_item_type: item.cost_item_type,
        id: params[:id]
      )
    end

    def controller_params
      params.permit(:id, :application_id, :save_and_exit)
    end

    def check_controller_params
      param_model = PriorAuthority::ServiceCostParams.new(controller_params)
      raise param_model.error_summary.to_s unless param_model.valid?
    end
  end
end
