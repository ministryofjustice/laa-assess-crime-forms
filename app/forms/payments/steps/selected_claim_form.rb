module Payments
  module Steps
    class SelectedClaimForm < BasePaymentsForm
      attribute :payment_request_claim_id
      attribute :claim_type

      validates :payment_request_claim_id, presence: true

      def save
        return false unless valid?

        claim.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      end

      private

      def claim
        @claim ||= if claim_type == 'Crm7SubmissionClaim'
                     SelectedSubmissionTransformer.new(payment_request_claim_id, multi_step_form_session).transform
                   else
                     SelectedClaimTransformer.new(payment_request_claim_id, multi_step_form_session).transform
                   end
      end
    end
  end
end
