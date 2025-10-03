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
      @claim_details = Payments::ClaimDetails.new({
                                                    'id' => 'e32b98c6-dc0a-4bd0-9035-5237faa81ae3',
        'claim_type' => 'non_standard_mag',
        'firm_name' => 'Law Laywers',
        'laa_reference' => 'LAA-1z5f76',
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
        'updated_at' => '2025-02-11T01:00:00.000Z',
        'payment_requests' => [
          {
            'id' => '7e1900d6-10c1-45fb-9208-64212761aac9',
            'request_type' => 'non_standard_mag',
            'allowed_profit_cost' => 140,
            'allowed_travel_cost' => 90,
            'allowed_waiting_cost' => 55.4,
            'allowed_disbursement_cost' => 200,
            'date_received' => '2025-01-10T01:00:00.000Z',
            'submitted_at' => '2025-01-11T01:00:00.000Z',
          },
          {
            'id' => '6e4c6221-5d56-431e-96cb-2e0512f55e3f',
            'request_type' => 'non_standard_mag_supplemental',
            'allowed_profit_cost' => 200,
            'allowed_travel_cost' => 90,
            'allowed_waiting_cost' => 55.4,
            'allowed_disbursement_cost' => 200,
            'date_received' => '2025-01-13T01:00:00.000Z',
            'submitted_at' => '2025-01-14T01:00:00.000Z',
          },
          {
            'id' => '8e2b6d81-c165-4734-b998-4af2eceaa8b0',
            'request_type' => 'non_standard_mag_appeal',
            'allowed_profit_cost' => 200,
            'allowed_travel_cost' => 150,
            'allowed_waiting_cost' => 55.4,
            'allowed_disbursement_cost' => 200,
            'date_received' => '2025-01-20T01:00:00.000Z',
            'submitted_at' => '2025-01-22T01:00:00.000Z',
          },
          {
            'id' => '7bf0b8c8-94f3-4c05-b3ca-04af93a300da',
            'request_type' => 'non_standard_mag_amendment',
            'allowed_profit_cost' => 200,
            'allowed_travel_cost' => 150,
            'allowed_waiting_cost' => 45.4,
            'allowed_disbursement_cost' => 200,
            'date_received' => '2025-01-22T06:00:00.000Z',
            'submitted_at' => '2025-01-22T08:00:00.000Z',
          }
        ]
                                                  })
      @current_page = params[:current_page] || 'payment_request'
      @selected_payment = selected_payment(@claim_details.payment_requests) || @claim_details.payment_requests.first
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

    def selected_payment(payments)
      payments.find { |payment| payment.id == params[:payment_id] }
    end
  end
end
