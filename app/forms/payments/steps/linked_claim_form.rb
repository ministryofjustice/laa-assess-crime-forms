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
        claim[:nsm_claim_id] = claim[:id]
        claim.except!(:payment_requests, :created_at, :updated_at, :type,
                      :id, :court_attendances, :matter_type, :no_of_defendants,
                      :outcome_code, :stage_code, :work_completed_date, :youth_court,
                      :court_name)
        claim.merge!(type: 'assigned_counsel')
      end

      def payment_request_claim
        @payment_request_claim ||= AppStoreClient.new.get_payment_request_claim(payment_request_claim_id)
      end
    end
  end
end
