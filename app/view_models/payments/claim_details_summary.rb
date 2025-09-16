module Payments
  class ClaimDetailsSummary < BaseCard
    CARD_ROWS = %i[
      claim_type
      claim_received
    ].freeze

    def claim_type
      session_answers['claim_type']
    end

    def claim_received
      session_answers['claim_received']
    end
  end
end
