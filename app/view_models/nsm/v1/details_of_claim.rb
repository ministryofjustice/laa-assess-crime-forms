module Nsm
  module V1
    class DetailsOfClaim < BaseViewModel
      attribute :ufn
      attribute :claim_type, :translated
      attribute :rep_order_date

      def key
        'details_of_claim'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def data
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.ufn"),
            value: ufn
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.claim_type"),
            value:  claim_type.to_s
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.rep_order_date"),
            value: format_in_zone(rep_order_date)
          }
        ]
      end

      def rows
        { title:, data: }
      end
    end
  end
end
