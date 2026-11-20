module PriorAuthority
  module V1
    class KeyInformation < ApplicationSummary
      def key_information_card
        ApplicationDetails::QuotesKeyInformationCard.new(self)
      end
    end
  end
end
