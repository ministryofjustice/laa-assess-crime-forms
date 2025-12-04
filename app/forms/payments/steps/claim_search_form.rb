module Payments
  module Steps
    class ClaimSearchForm < Payments::SearchForm
      attribute :query, :string
      attribute :search_scope, :string

      validates :query, presence: true

      def executed?
        @search_response.present?
      end

      def search_params
        attributes.merge(per_page: self.class::PER_PAGE).compact_blank
      end
    end
  end
end
