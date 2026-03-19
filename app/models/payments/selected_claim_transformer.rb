module Payments
  class SelectedClaimTransformer < BaseSelectedTransformer
    private

    def claim
      @claim ||= raw_claim.merge('court_name' => court_name, 'court_id' => court_id).except('court')
    end

    def raw_claim
      @raw_claim ||= AppStoreClient.new.get_payable_claim(payable_claim_id)
                                   .deep_stringify_keys.with_indifferent_access
    end

    def court_item
      LaaCrimeFormsCommon::Court.all.find { |c| @raw_claim['court'].downcase == c.name.downcase }
    end

    def court_id
      court_item&.id || I18n.t('laa_crime_forms_common.shared.custom')
    end

    def court_name
      court_item&.short_name || @raw_claim['court'].delete_suffix(" - #{I18n.t('laa_crime_forms_common.shared.na')}")
    end
  end
end
