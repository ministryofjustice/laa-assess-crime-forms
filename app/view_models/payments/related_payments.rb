module Payments
  class RelatedPayments
    def initialize(payment_request_claim, related_payment_params)
      @related_claim = payment_request_claim['assigned_counsel_claim'] || payment_request_claim['nsm_claim']
      @sort_by = related_payment_params[:sort_by]
      @sort_direction = related_payment_params[:sort_direction]
      @per_page = related_payment_params[:per_page]
      @page = related_payment_params[:page]
    end

    def sorted_payments
      offset = (@page - 1) * @per_page
      delta = (@page * @per_page) - 1
      records = formatted_payments.sort_by { |payment| payment[@sort_by.to_sym] }
      sorted_records = @sort_direction == 'descending' ? records.reverse : records
      sorted_records[offset..delta]
    end

    # rubocop:disable Rails/Delegate
    def count
      payment_requests.count
    end
    # rubocop:enable Rails/Delegate

    private

    def formatted_payments
      payment_requests.map do |request|
        {
          laa_reference: laa_reference,
          request_type: I18n.t("payments.request_types.#{request['request_type']}"),
          firm_name: firm_name,
          defendant_last_name: defendant_last_name,
          submitted_at: DateTime.parse(request['submitted_at']),
          link: link
        }
      end
    end

    def payment_requests
      @related_claim&.dig('payment_requests') || []
    end

    def payment_request_claim_id
      @related_claim['id']
    end

    def laa_reference
      @related_claim['laa_reference']
    end

    def firm_name
      @related_claim['counsel_office_code'] || @related_claim['solicitor_office_code']
    end

    def defendant_last_name
      @related_claim['client_last_name']
    end

    def link
      "/payments/requests/#{payment_request_claim_id}"
    end
  end
end
