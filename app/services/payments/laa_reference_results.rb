module Payments
  class LaaReferenceResults
    def call(source)
      case source
      when :payments
        get_payments
      when :submissions
        # get_submissions
      when :all
        # get_payments.concat(get_submissions)
      else
        raise source ? "Unknown source '#{source}'" : 'No source supplied'
      end
    end

    private

    def get_payments
      page = 1
      results = []
      loop do
        payload = AppStoreClient.new.search(search_params(page), :payment_requests)

        # there are potentially multiple results per laa ref for payments - may need to use uniq
        results.concat(payload['data'].map { format_payment(_1) })
        metadata = payload['metadata']

        break if check_last_page(metadata)

        page += 1
      end
      results
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

    def check_last_page(metadata)
      total    = metadata['total_results'].to_i
      per_page = metadata['per_page'].to_i
      current_page  = metadata['page'].to_i

      (current_page * per_page) >= total
    end

    def search_params(page)
      {
        page: page,
        sort_direction: 'descending'
      }
    end
  end
end
