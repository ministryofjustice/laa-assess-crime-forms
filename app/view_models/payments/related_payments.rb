module Payments
  class RelatedPayments
    def initialize(related_claim, sort_params)
      @related_claim = related_claim
      @sort_by = sort_params[:sort_by] || 'submitted_at'
      @sort_direction = sort_params[:sort_direction] || 'descending'
    end

    def sorted_payments
      records = payments.sort_by { |payment| payment[@sort_by.to_sym] }
      @sort_direction == 'descending' ? records.reverse : records
    end

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
      @related_claim['firm_name']
    end

    def client_last_name
      @related_claim['client_last_name']
    end

    def link
      "/payments/requests/#{payment_request_claim_id}"
    end
  end
end
