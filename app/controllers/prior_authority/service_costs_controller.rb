module PriorAuthority
  class ServiceCostsController < PriorAuthority::BaseController
    def edit
      submission = PriorAuthorityApplication.find(params[:application_id])
      authorize(submission, :edit?)
      all_service_costs = BaseViewModel.build(:service_cost, submission, 'quotes')

      item = all_service_costs.find do |model|
        model.id == params[:id]
      end

      form = ServiceCostForm.new(submission:, item:, **item.form_attributes)

      render locals: { submission:, item:, form: }
    end

    def update
      submission = PriorAuthorityApplication.find(params[:application_id])
      authorize(submission, :update?)
      all_service_costs = BaseViewModel.build(:service_cost, submission, 'quotes')

      item = all_service_costs.find do |model|
        model.id == params[:id]
      end

      form = ServiceCostForm.new(submission:, item:, **form_params(item))

      if form.save!
        redirect_to prior_authority_application_adjustments_path(submission)
      else
        render :edit, locals: { submission:, item:, form: }
      end
    end

    def confirm_deletion
      submission = PriorAuthorityApplication.find(params[:application_id])
      authorize(submission, :edit?)
      service_type = t(submission.data['service_type'], scope: 'prior_authority.service_types')
      render 'prior_authority/shared/confirm_delete_adjustment',
             locals: { item_name: t('.service_type_cost', service_type:),
                       deletion_path: prior_authority_application_service_cost_path(submission, params[:id]) }
    end

    def destroy
      deleter = PriorAuthority::AdjustmentDeleter.new(params, :service_cost, current_user)
      authorize(deleter.submission, :update?)
      deleter.call!
      redirect_to prior_authority_application_adjustments_path(params[:application_id])
    end

    private

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
  end
end
