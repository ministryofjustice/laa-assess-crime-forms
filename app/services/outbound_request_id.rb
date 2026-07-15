require 'request_store'

class OutboundRequestId
  STORE_KEY = :outbound_request_id
  SERVICE_PREFIX = 'nscc-assess'.freeze
  UUID_PATTERN = /\A(?:[0-9a-f]{32}|[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})\z/i

  class << self
    def set(request_id)
      RequestStore.store[STORE_KEY] = normalised_uuid(request_id) if request_id.present?
    end

    def current
      uuid = RequestStore.store[STORE_KEY].presence || normalised_uuid
      "#{SERVICE_PREFIX}-#{uuid}"
    end

    def headers
      { 'request-id' => current }
    end

    private

    def normalised_uuid(request_id = nil)
      uuid = request_id.to_s.delete_prefix("#{SERVICE_PREFIX}-")
      uuid = SecureRandom.uuid unless uuid.match?(UUID_PATTERN)

      uuid.delete('-').downcase
    end
  end
end
