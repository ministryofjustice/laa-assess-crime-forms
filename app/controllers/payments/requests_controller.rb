module Payments
  class RequestsController < ApplicationController
    include Payments::MultiStepFormSessionConcern

    layout 'payments'

    before_action :set_current
    before_action :authorize_caseworker
    before_action :set_default_table_sort_options, only: %i[index show]

    RELATED_PAYMENTS_LIMIT = 10

    def index
      model = Payments::SearchResults.new(controller_params.permit(:page, :sort_by, :sort_direction))
      model.execute

      render :index, locals: { pagy: model.pagy, requests: model.results }
    end

    def show
      @claim_details = payment_request_claim
      @current_page = controller_params[:current_page] || 'payment_request'
      @selected_payment = selected_payment(@claim_details.payment_requests) || @claim_details.payment_requests.first
      @related_payments_pagy = Pagy.new(**related_payments_pagy_params)
    end

    def new
      redirect_to edit_payments_steps_claim_types_path(id: cycle_multi_step_form_session_object.id)
    end

    def confirmation; end

    def create
      response = AppStoreClient.new.create_payment_request(request_payload)
      destroy_current_form_sessions
      @payment_confirmation = Payments::ConfirmationSummary.new(response)

      render :confirmation
    rescue RuntimeError => e
      destroy_current_form_sessions

      raise e
    end

    private

    def related_payments_pagy_params
      {
        count: @claim_details.related_payments.count,
        limit: related_payment_params[:per_page],
        page: related_payment_params[:page],
        fragment: '#related-payments'
      }
    end

    def request_payload
      current_multi_step_form_session.answers.merge('submitter_id' => current_user.id)
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

    def param_validator
      @param_validator ||= Payments::RequestsParams.new(controller_params)
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
        sort_direction: controller_params[:sort_direction] || 'ascending'
      }
    end

    def payment_request_claim
      response = AppStoreClient.new.get_payment_request_claim(controller_params[:id])
      claim_type = response['type']
      claim_details_class = nil
      if claim_type == 'NsmClaim'
        claim_details_class = Payments::NsmClaimDetails
      elsif claim_type == 'AssignedCounselClaim'
        claim_details_class = Payments::AssignedCounselClaimDetails
      else
        raise "Invalid claim type: #{claim_type}"
      end

      claim_details_class.new(response, related_payment_params)
    end
  end
end
