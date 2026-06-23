module Payments
  module Steps
    class OfficeCodeSearchForm < BasePaymentsForm
      attribute :solicitor_office_code, :string

      validates :solicitor_office_code, presence: true, office_code: true

      def save
        return false unless valid?
        return false unless provider_available?

        multi_step_form_session[:solicitor_office_code] = solicitor_office_code

        true
      end

      private

      def provider_available?
        ProviderData::ProviderDataClient.new.contracted_office_details(solicitor_office_code)
        true
      rescue ProviderData::ProviderDataApiClient::ProviderUnavailableError => e
        Sentry.capture_exception(e)
        errors.add(:base, :provider_unavailable)
        false
      end
    end
  end
end
