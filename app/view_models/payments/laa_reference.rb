module Payments
  class LaaReference
    def initialize(reference, client_surname)
      @reference = reference
      @client_surname = client_surname
    end

    def value
      @reference
    end

    def description
      "#{@reference} - #{I18n.t('shared.claim_reference_form.defendant')} #{@client_surname}"
    end
  end
end
