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

    def new
      redirect_to edit_payments_steps_claim_types_path(id: new_multi_step_form_session_object.id)
    end

    def confirmation; end

    # rubocop:disable Metrics/AbcSize
    def create
      payload = multi_step_form_session.answers.merge('submitter_id' => current_user.id)
      response = AppStoreClient.new.create_payment_request(payload)

      if response['errors'].present?

        flash[:alert] = response['errors'] ||
                        'Something went wrong submitting your payment request.'
        redirect_to payments_steps_check_your_answers_path(id: multi_step_form_session.id)
      else
        session.delete(:multi_step_form_id)
        redirect_to payments_request_confirmation_path
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def multi_step_form_session
      @multi_step_form_session ||= Decisions::MultiStepFormSession.new(
        process: 'payments',
        session: session,
        session_id: session[:multi_step_form_id]
      )
    end

    def new_multi_step_form_session_object
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

    def payment_request_params
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

    def search_params_validator
      @search_params_validator ||= SearchPaymentRequestParams.new(controller_params)
    end

    def payment_request_params_validator
      @payment_request_params_validator ||= PaymentRequestParams.new(payment_request_params)
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
