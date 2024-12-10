module Nsm
  module AdjustmentConcern
    extend ActiveSupport::Concern
    def confirm_deletion
      authorize(claim, :update?)
      @adjustment = adjustments.find { _1.id == params[:id] }
      render :confirm_delete_adjustment, locals: { claim_id: params[:claim_id], id: params[:id] }
    end

    def destroy
      authorize(claim, :update?)
      Nsm::AdjustmentDeleter.new(params, resource_klass, current_user, claim).call!
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def destroy_redirect
      claim.any_adjustments? ? { action: :adjusted } : nsm_claim_work_items_path
    end

    def adjustments
      @adjustments ||= if additional_fee?
                         check_additional_fee_adjustments
                       else
                         BaseViewModel
                           .build(resource_klass, claim, nesting)
                           .filter(&:any_adjustments?)
                       end
    end

    def resource_klass
      return :letter_and_call if json_search_field == 'letters_and_calls'
      return :additional_fee if json_search_field == 'additional_fees'

      @resource_klass ||= controller_name.singularize.to_sym
    end

    def json_search_field
      @json_search_field ||= controller_name
    end

    def nesting
      additional_fee? ? nil : json_search_field
    end

    def additional_fee?
      json_search_field == 'additional_fees'
    end

    def check_additional_fee_adjustments
      return unless params[:id] == 'youth_court_fee'

      claim['include_youth_court_fee_original'] && (claim['include_youth_court_fee'] != claim['include_youth_court_fee_original'])
    end
  end
end
