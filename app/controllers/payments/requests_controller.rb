module Payments
  class RequestsController < ApplicationController
    layout 'payments'

    before_action :set_current
    before_action :authorize_caseworker
    before_action :set_default_table_sort_options, only: %i[index]

    def index
      model = Payments::SearchResults.new(controller_params.permit(:page, :sort_by, :sort_direction))
      model.execute

      render :index, locals: { pagy: model.pagy, requests: model.results }
    end

    def show
      @request_id = SecureRandom.uuid
      @claim_details = Payments::ClaimDetails.new({
        'claim_type' => 'non_standard_mag',
        'date_received' => 1.day.ago,
        'office_code' => 'A100129',
        'ufn' => '20250112/001',
        'stage_reached' => 'PROG',
        'defendant_first_name' => 'Du',
        'defendant_last_name' => 'Bois',
        'number_of_attendances' => 3,
        'number_of_defendants' => 1,
        'hearing_outcome_code' => 'CP01',
        'matter_type' => '2 - Homicide and related grave offences',
        'court' => 'Acton - C2723',
        'youth_court' => true,
        'date_completed' => DateTime.now
      })
      @current_page = params[:current_page] || 'payment_request'
    end

    def new
      redirect_to edit_payments_steps_claim_types_path(id: multi_step_form_session_object.id)
    end

    private

    def multi_step_form_session_object
      if session[:multi_step_form_id].present?
        destroy_current_form_session && create_new_form_session
      else
        create_new_form_session
      end
    end

    def authorize_caseworker
      authorize :payment, :show?
    end

    def controller_params
      params.permit(
        :id,
        :sort_by,
        :sort_direction,
        :page
      )
    end

    def destroy_current_form_session
      ['multi_step_form_id', "payments:#{session[:multi_step_form_id]}"].each { session.delete(_1) }
    end

    def create_new_form_session
      session[:multi_step_form_id] = SecureRandom.uuid
      Decisions::MultiStepFormSession.new(process: 'payments',
                                          session: session,
                                          session_id: session[:multi_step_form_id])
    end

    def param_validator
      @param_validator ||= PaymentRequestParams.new(controller_params)
    end

    def set_default_table_sort_options
      @sort_by = controller_params.fetch(:sort_by, 'submitted_at')
      @sort_direction = controller_params.fetch(:sort_direction, 'ascending')
    end

    def set_current
      @current = :requests
    end
  end
end
