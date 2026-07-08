require 'request_store'

class OutboundRequestId
  STORE_KEY = :outbound_request_id
  SERVICE_PREFIX = 'nscc-assess'.freeze

  class << self
    def set(request_id)
      RequestStore.store[STORE_KEY] = request_id.to_s if request_id.present?
    end

    def current
      with_service_prefix(RequestStore.store[STORE_KEY].presence || SecureRandom.uuid)
    end

    def headers
      { 'request-id' => current }
    end

    private

    def with_service_prefix(request_id)
      request_id = request_id.to_s
      return request_id if request_id.start_with?("#{SERVICE_PREFIX}-")

      "#{SERVICE_PREFIX}-#{request_id}"
    end
  end
end
