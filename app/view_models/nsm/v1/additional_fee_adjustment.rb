module Nsm
  module V1
    class AdditionalFeeAdjustment < BaseViewModel
      attribute :claim
      attribute :fee_type

      def reason
        claim.youth_court_adjustment_comment if fee_type == 'youth_court_fee'
      end

      def type_name
        fee_type
      end

      def allowed_net
        NumberTo.pounds(claim.additional_fees[fee_type]['assessed_total_exc_vat'])
      end
    end
  end
end
