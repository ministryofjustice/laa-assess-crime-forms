module Payments
  class SearchResult
    attr_accessor :row

    def initialize(row)
      @row = row
    end

    delegate :payment_request_id, to: :row

    delegate :laa_reference, to: :row

    delegate :payment_type, to: :row

    delegate :client_last_name, to: :row

    delegate :submitted_at, to: :row
  end
end
