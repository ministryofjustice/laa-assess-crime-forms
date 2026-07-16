require 'csv'

module Payments
  class DownloadController < ApplicationController
    layout 'payments'

    before_action :authorize_payments

    CSV_COLUMNS = %i[
      claim_id
      court_attendances
      court_name
      court_id
      no_of_defendants
      outcome_code
      office_name
      office_code
      stage_code
      ufn
      laa_reference
      work_completed_date
      original_submission_date
      youth_court
      client_last_name
      request_type
      allowed_disbursement_cost
      claimed_disbursement_cost
      allowed_profit_cost
      claimed_profit_cost
      allowed_travel_cost
      claimed_travel_cost
      allowed_waiting_cost
      claimed_waiting_cost
      claimed_total
      allowed_total
      date_received
      submitted_at
    ].freeze

    def index
      return unless search_params.to_h.any?

      @results = AppStoreClient.new.search(search_params, :payment_requests).deep_symbolize_keys
      return unless request.format.csv?

      send_data(
        csv_data(@results.fetch(:data, [])),
        filename: "payments-download-#{Time.zone.today.iso8601}.csv",
        type: 'text/csv',
        disposition: 'attachment'
      )
    end

    def show
      redirect_to payments_download_index_path(search_params.merge(format: :csv))
    end

    private

    def search_params
      params.permit(:created_at_from, :created_at_to, request_type: [])
    end

    def authorize_payments
      authorize(:payment, :index?)
    end

    def csv_data(rows)
      CSV.generate(headers: true) do |csv|
        csv << CSV_COLUMNS
        rows.each do |row|
          csv << CSV_COLUMNS.map { |column| row[column] }
        end
      end
    end
  end
end
