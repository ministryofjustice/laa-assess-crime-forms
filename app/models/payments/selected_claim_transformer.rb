module Payments
  class SelectedClaimTransformer < BaseSelectedTransformer
    private

    def claim
      @claim ||= AppStoreClient.new.get_payable_claim(payable_claim_id)
                               .deep_stringify_keys.with_indifferent_access
    end
  end
end
