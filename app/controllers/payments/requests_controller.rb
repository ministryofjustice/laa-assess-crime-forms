module Payments
  class RequestsController < ApplicationController
    include Payments::MultiStepFormSessionConcern

    layout 'payments'

    before_action :set_current
    before_action :authorize_caseworker
    before_action :set_default_table_sort_options, only: %i[index]

    def index
      model = Payments::SearchResults.new(controller_params.permit(:page, :sort_by, :sort_direction))
      model.execute

      render :index, locals: { pagy: model.pagy, requests: model.results }
    end

    def new
      redirect_to edit_payments_steps_claim_types_path(id: cycle_multi_step_form_session_object.id)
    end

    def confirmation; end

    def create
      response = AppStoreClient.new.create_payment_request(request_payload)

      if response['errors'].present?
        flash[:alert] = response['errors']
        redirect_to payments_steps_check_your_answers_path(id: current_multi_step_form_session.id)
      else
        @payment_confirmation = Payments::ConfirmationSummary.new(response)
        render :confirmation
      end
    end

    private

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
        :page
      )
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
