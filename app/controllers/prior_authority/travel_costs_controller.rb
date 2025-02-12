module PriorAuthority
  class TravelCostsController < PriorAuthority::BaseController
    def edit
      authorize(submission, :edit?)
      all_travel_costs = BaseViewModel.build(:travel_cost, submission, 'quotes')

      item = all_travel_costs.find do |model|
        model.id == controller_params[:id]
      end

      form = TravelCostForm.new(submission:, item:, **item.form_attributes)

      render locals: { submission:, item:, form: }
    end

    def update
      authorize(submission, :update?)
      all_travel_costs = BaseViewModel.build(:travel_cost, submission, 'quotes')

      item = all_travel_costs.find do |model|
        model.id == controller_params[:id]
      end

      form = TravelCostForm.new(submission:, item:, **form_params)

      if form.save!
        redirect_to prior_authority_application_adjustments_path(submission)
      else
        render :edit, locals: { submission:, item:, form: }
      end
    end

    def confirm_deletion
      authorize(submission, :edit?)
      render 'prior_authority/shared/confirm_delete_adjustment',
             locals: { item_name: t('.travel_cost'),
                       deletion_path: prior_authority_application_travel_cost_path(controller_params[:application_id],
                                                                                   controller_params[:id]) }
    end

    def destroy
      authorize(submission, :update?)
      deleter = PriorAuthority::AdjustmentDeleter.new(controller_params, :travel_cost, current_user, submission)
      deleter.call!
      redirect_to prior_authority_application_adjustments_path(controller_params[:application_id])
    end

    private

    def form_params
      params.expect(
        prior_authority_travel_cost_form: [:travel_time,
                                           :travel_cost_per_hour,
                                           :explanation],
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

    def param_validator
      @param_validator ||= PriorAuthority::CostsParams.new(controller_params)
    end
  end
end
