require 'selenium-webdriver'

module SeleniumStaleNodeResponse
  STALE_NODE_MESSAGE = 'Node with given id does not belong to the document'.freeze

  def error
    response_error = super
    return response_error unless response_error.is_a?(Selenium::WebDriver::Error::UnknownError) &&
                                 response_error.message.include?(STALE_NODE_MESSAGE)

    stale_error = Selenium::WebDriver::Error::StaleElementReferenceError.new(response_error.message)
    stale_error.set_backtrace(response_error.backtrace)

    begin
      raise stale_error, cause: response_error.cause
    rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
      e
    end
  end
end

response_class = Selenium::WebDriver::Remote::Response
response_class.prepend(SeleniumStaleNodeResponse) unless response_class.ancestors.include?(SeleniumStaleNodeResponse)
