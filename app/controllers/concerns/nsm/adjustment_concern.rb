module Nsm
  module AdjustmentConcern
    extend ActiveSupport::Concern
    # rubocop:disable Style/NumberedParameters, Metrics/AbcSize
    def confirm_deletion
      authorize(claim, :update?)
      raise 'Attempting to delete non-existent adjusment' if additional_fee? && !view_model.any_adjustments?

      @adjustment = if additional_fee?
                      view_model
                    else
                      view_model.filter(&:any_adjustments?).find do
                        _1.id == params[:id]
                      end
                    end

      render :confirm_delete_adjustment, locals: { claim_id: params[:claim_id], id: params[:id] }
    end
    # rubocop:enable Style/NumberedParameters, Metrics/AbcSize

    def destroy
      authorize(claim, :update?)
      Nsm::AdjustmentDeleter.new(params, resource_klass, current_user, claim).call!
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def destroy_redirect
      claim.any_adjustments? ? { action: :adjusted } : nsm_claim_work_items_path
    end

    def view_model
      @view_model ||= BaseViewModel.build(resource_klass, claim, nesting)
    end

    def nesting
      additional_fee? ? nil : json_search_field
    end

    def additional_fee?
      json_search_field == 'additional_fees'
    end

    def resource_klass
      return :letter_and_call if json_search_field == 'letters_and_calls'
      return params[:id].to_sym if additional_fee?

      @resource_klass ||= controller_name.singularize.to_sym
    end

    def json_search_field
      @json_search_field ||= controller_name
    end
  end
end
