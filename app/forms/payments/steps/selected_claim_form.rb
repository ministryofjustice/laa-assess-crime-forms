module Payments
  module Steps
    class SelectedClaimForm < BasePaymentsForm
      attribute :payment_request_claim_id
      attribute :claim_type

      validates :payment_request_claim_id, presence: true
      validates :claim_type, presence: true,
        inclusion: { in: %w[Crm7SubmissionClaim NsmClaim AssignedCounselClaim] }

      def save
        return false unless valid?

        claim.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      end

      private

      def claim
        @claim ||= transformer_class.new(payment_request_claim_id, multi_step_form_session).transform
      end

      def transformer_class
        claim_type == 'Crm7SubmissionClaim' ? SelectedSubmissionTransformer : SelectedClaimTransformer
      end
    end
  end
end
