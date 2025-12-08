module Payments
  module Steps
    class LinkedClaimForm < BasePaymentsForm
      attribute :payment_request_claim_id

      validates :payment_request_claim_id, presence: true

      def save
        return false unless valid?

        raise StandardError unless claim

        claim.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      end

      def claim
        claim = payment_request_claim.deep_stringify_keys.with_indifferent_access
        case claim['type']
        when 'non_standard_magistrate'
          {
            'nsm_claim_id' => claim[:id],
            'defendant_last_name' => claim[:client_last_name],
            'solicitor_office_code' => claim[:solicitor_office_code],
            'solicitor_firm_name' => claim[:solicitor_firm_name]
          }
        when 'assigned_counsel'
          {
            'counsel_office_code' => claim[:counsel_office_code],
            'counsel_firm_name' => claim[:counsel_firm_name],
            'defendant_last_name' => claim[:client_last_name],
            'ufn' => claim[:ufn]
          }
        end
      end

      def payment_request_claim
        @payment_request_claim ||= AppStoreClient.new.get_payment_request_claim(payment_request_claim_id)
      end
    end
  end
end
