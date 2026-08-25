require 'rails_helper'

RSpec.describe SeleniumStaleNodeResponse do
  subject(:response) { Selenium::WebDriver::Remote::Response.new(response_code, payload) }

  let(:response_code) { 500 }
  let(:payload) do
    {
      'value' => {
        'error' => webdriver_error,
        'message' => error_message,
        'stacktrace' => [
          {
            'fileName' => 'document.cc',
            'lineNumber' => 123,
            'methodName' => 'resolveNode'
          }
        ]
      }
    }
  end
  let(:webdriver_error) { 'unknown error' }
  let(:error_message) { 'browser error' }

  it 'is prepended once to the Selenium response class' do
    ancestors = Selenium::WebDriver::Remote::Response.ancestors

    expect(ancestors.count(described_class)).to eq(1)
  end

  context 'with the Chrome stale-node error' do
    let(:error_message) do
      'unknown error: unhandled inspector error: ' \
        '{"code":-32000,"message":"Node with given id does not belong to the document"}'
    end

    it 'returns a retryable stale element error with the original details' do
      expect { response }.to raise_error(Selenium::WebDriver::Error::StaleElementReferenceError) do |error|
        expect(error.message).to start_with(error_message)
        expect(error.backtrace.first).to include('selenium/webdriver/remote/response.rb')
        expect(error.cause).to be_a(Selenium::WebDriver::Error::WebDriverError)
        expect(error.cause.backtrace).to contain_exactly("[remote server] document.cc:123:in `resolveNode'")
      end
    end

    it 'is an error Capybara retries' do
      retryable_errors = Capybara::Selenium::Driver.allocate.invalid_element_errors

      expect { response }.to raise_error do |error|
        expect(retryable_errors.any? { |error_class| error.is_a?(error_class) }).to be(true)
      end
    end
  end

  context 'with an unrelated unknown error' do
    it 'remains an unknown error' do
      expect { response }.to raise_error(Selenium::WebDriver::Error::UnknownError, error_message)
    end
  end

  context 'with a successful response' do
    let(:response_code) { 200 }
    let(:payload) { { 'value' => 'success' } }

    it 'leaves the nil error result unchanged' do
      expect(response.error).to be_nil
    end
  end
end
