module Payments
  class RelatedPayments
    def initialize(related_claim, related_payment_params)
      @related_claim = related_claim
      @sort_by = related_payment_params[:sort_by]
      @sort_direction = related_payment_params[:sort_direction]
      @per_page = related_payment_params[:per_page]
      @page = related_payment_params[:page]
    end

    def sorted_payments
      if @sort_by && @sort_direction
        offset =  (@page - 1) * @per_page
        delta = (@page * @per_page) - 1
        records = payments.sort_by { |payment| payment[@sort_by.to_sym] }
        sorted_records = @sort_direction == 'descending' ? records.reverse : records
        sorted_records[offset..delta]
      else
        payments
      end
    end

    delegate :count, to: :payments

    private

    def payments
      @related_claim['payment_requests'].map do |request|
        {
          laa_reference: laa_reference,
          request_type: I18n.t("payments.request_types.#{request['request_type']}"),
          firm_name: firm_name,
          client_last_name: client_last_name,
          submitted_at: DateTime.parse(request['submitted_at']),
          link: link
        }
      end
    end

    def payment_request_claim_id
      @related_claim['id']
    end

    def laa_reference
      @related_claim['laa_reference']
    end

    def firm_name
      @related_claim['counsel_firm_name'] || @related_claim['firm_name']
    end

    def client_last_name
      @related_claim['client_last_name']
    end

    def link
      "/payments/requests/#{payment_request_claim_id}"
    end
  end
end
