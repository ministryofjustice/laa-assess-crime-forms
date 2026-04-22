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
      row[:payable_claim][:laa_reference]
    end

    def payable_claim_id
      row[:payable_claim][:id]
    end

    def defendant_last_name
      row[:payable_claim][:client_last_name]
    end

    def request_type
      row[:request_type]
    end

    def firm_name
      row[:payable_claim][:counsel_firm_name] || row[:payable_claim][:solicitor_firm_name]
    end

    def submitted_at
      Time.zone.parse(row[:submitted_at]).to_fs(:stamp)
    end
  end
end
