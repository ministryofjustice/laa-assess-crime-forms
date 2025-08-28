module Payments
  class SearchResult
    attr_accessor :row

    def initialize(row)
      @row = row
    end

    def payment_request_id
      row[:id]
    end

    def laa_reference
      row[:payment_request_claim][:laa_reference]
    end

    def client_last_name
      row[:payment_request_claim][:client_last_name]
    end

    def payment_type
      row[:payment_request_claim][:claim_type]
    end

    def submitted_at
      row[:submitted_at]
    end
  end
end
