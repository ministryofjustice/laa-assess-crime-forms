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

    private

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
