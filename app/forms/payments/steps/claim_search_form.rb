module Payments
  module Steps
    class ClaimSearchForm < Payments::SearchForm
      attribute :query, :string
      attribute :request_type, :string
      attribute :sort_by, :string, default: 'created_at'

      validates :query, presence: true

      def executed?
        @search_response.present?
      end

      def search_params
        attributes.merge(per_page: self.class::PER_PAGE).compact_blank
      end

      def conduct_search
        AppStoreClient.new.search(search_params, :linked_claim).deep_symbolize_keys
      rescue StandardError => e
        Sentry.capture_exception(e)
        errors.add(:base, :search_error)
        nil
      end

      def results
        @search_response[:data].map { Payments::LinkedSearchResult.new(_1) }
      end
    end
  end
end
