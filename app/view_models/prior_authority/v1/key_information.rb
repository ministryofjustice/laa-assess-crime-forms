module PriorAuthority
  module V1
    class KeyInformation < ApplicationSummary
      def quotes_key_information_card
        ApplicationDetails::QuotesKeyInformationCard.new(self)
      end

      def key_information_card
        quotes_key_information_card
      end
    end
  end
end
