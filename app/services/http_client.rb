class HttpClient
  include HTTParty

  headers 'Content-Type' => 'application/json'

  def headers
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def host
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def options(payload = nil)
    options = payload ? { body: payload.to_json } : {}
    options.merge(headers:)
  end

  def process_response(response, error_message, response_maps)
    outcome = response_maps.detect { _1[0] == response.code || (_1[0].is_a?(Range) && _1[0].include?(response.code)) }&.last

    raise error_message unless outcome

    if outcome.respond_to?(:call)
      outcome.call(response.body)
    else
      outcome
    end
  end
end
