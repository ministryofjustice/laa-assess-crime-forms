module Payments
  module Steps
    class ClaimTypeForm < BasePaymentsForm
      attribute :claim_type, :string

      private

      def persist!; end
    end
  end
end
