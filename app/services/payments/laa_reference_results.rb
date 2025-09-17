module Payments
  class LaaReferenceResults
    def call(source, query, total_results)
      case source
      when :payments
        get_payments(query, total_results)
      when :submissions
        # get_submissions
      when :all
        # get_payments.concat(get_submissions)
      else
        raise source ? "Unknown source '#{source}'" : 'No source supplied'
      end
    end

    private

    def get_payments(query, total_results)
      payload = AppStoreClient.new.search(search_params(query, total_results), :payment_requests)
      # there are potentially multiple results per laa ref for payments - may need to use uniq
      payload['data'].map { format_payment(_1) }
    end

    # def get_submissions
    #   loop do
    #     AppStoreClient.new.search(search_params, :submissions)
    #   end
    # end

    def format_payment(entry)
      reference = entry.dig('payment_request_claim', 'laa_reference')
      surname   = entry.dig('payment_request_claim', 'client_last_name').upcase
      Payments::LaaReference.new(reference, surname)
    end

    def search_params(query, total_results)
      params = {
        sort_direction: 'descending',
        query: query
      }

      params[:per_page] = total_results if total_results
      params
    end
  end
end
