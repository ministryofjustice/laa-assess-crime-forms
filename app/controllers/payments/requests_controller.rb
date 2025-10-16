module Payments
  class RequestsController < ApplicationController
    layout 'payments'

    before_action :set_current
    before_action :authorize_caseworker
    before_action :set_default_table_sort_options, only: %i[index show]

    RELATED_PAYMENTS_LIMIT = 10

    def index
      model = Payments::SearchResults.new(controller_params.permit(:page, related_payment_params))
      model.execute

      render :index, locals: { pagy: model.pagy, requests: model.results }
    end

    def show
      details_class = "Payments::#{payment_request_claim['type']}Details".constantize
      @claim_details = details_class.new(payment_request_claim, related_payment_params)
      @current_page = controller_params[:current_page] || 'payment_request'
      @selected_payment = selected_payment(@claim_details.payment_requests) || @claim_details.payment_requests.first
      @related_payments_pagy = Pagy.new(
        count: @claim_details.related_payments.count,
        limit: related_payment_params[:per_page],
        page: related_payment_params[:page],
        fragment: '#related-payments'
      )
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
        :page,
        :current_page,
        :payment_id
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
      payments.find { |payment| payment.id == controller_params[:payment_id] }
    end

    def related_payment_params
      {
        page: controller_params[:page] ? controller_params[:page].to_i : 1,
        per_page: RELATED_PAYMENTS_LIMIT,
        sort_by: controller_params[:sort_by] || 'submitted_at',
        sort_direction: controller_params[:sort_direction] || 'descending'
      }
    end

    def payment_request_claim
      @payment_request_claim ||= AppStoreClient.new.get_payment_request_claim(controller_params[:id])
    end
  end
end
