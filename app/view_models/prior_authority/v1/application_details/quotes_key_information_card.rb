module PriorAuthority
  module V1
    class ApplicationDetails
      class QuotesKeyInformationCard < BaseCard
        CARD_ROWS = %i[
          main_offence
          existing_prior_authority_granted
          ordered_by_court
        ].freeze

        delegate :main_offence, :prior_authority_granted, to: :application_details

        def existing_prior_authority_granted
          I18n.t("shared.#{prior_authority_granted}")
        end

        def ordered_by_court
          I18n.t("shared.#{quote&.ordered_by_court.nil? ? false : quote.ordered_by_court}")
        end

        private

        def quote
          @quote ||= application_details.primary_quote
        end
      end
    end
  end
end
