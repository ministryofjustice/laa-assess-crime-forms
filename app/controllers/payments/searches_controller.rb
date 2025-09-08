module Payments
  class SearchesController < ApplicationController
    layout 'payments'

    before_action :set_current
    before_action :authorize_payments

    def show
      @search_form = Payments::SearchForm.new(search_params)
      @search_form.execute if @search_form.valid?
    end

    def new
      @search_form = Payments::SearchForm.new(default_params)
      render :show
    end

    private

    def search_params
      params.expect(
        payments_search_form: [:query,
                               :submitted_from,
                               :submitted_to,
                               :received_from,
                               :received_to,
                               :request_type,
                               :sort_by,
                               :sort_direction]
      ).merge(default_params)
    end

    def default_params
      {
        page: params.fetch(:page, '1')
      }
    end

    def set_current
      @current = :search
    end

    def authorize_payments
      authorize(:payment, :index?)
    end
  end
end
