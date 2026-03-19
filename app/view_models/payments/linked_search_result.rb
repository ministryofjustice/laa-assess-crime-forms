module Payments
  class LinkedSearchResult
    attr_accessor :row

    def initialize(row)
      @row = row
    end

    def payable_claim_id
      row[:id]
    end

    def laa_reference
      row[:laa_reference]
    end

    def defendant_last_name
      row[:defendant_last_name]
    end

    def firm_name
      row[:solicitor_firm_name]
    end

    def ufn
      row[:ufn]
    end

    def claim_type
      row[:type]
    end

    def office_code
      row[:solicitor_office_code]
    end
  end
end
