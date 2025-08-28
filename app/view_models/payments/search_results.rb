module Payments
  class SearchResults < ::SearchResults
    attribute :sort_by, :string, default: 'submitted_at'

    def results
      @search_response[:data].map { Payments::SearchResult.new(_1) }
    end

    def conduct_search
      AppStoreClient.new.search(search_params, :payments).deep_symbolize_keys
    end
  end
end
