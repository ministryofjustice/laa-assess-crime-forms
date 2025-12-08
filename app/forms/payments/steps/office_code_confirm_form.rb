module Payments
  module Steps
    class OfficeCodeConfirmForm < BasePaymentsForm
      attribute :confirm_office_code, :boolean

      validates :confirm_office_code, presence: true

      def save
        return false unless valid?

        if confirm_office_code

          multi_step_form_session[:solicitor_office_code] = multi_step_form_session[:office_code_search]
          multi_step_form_session[:solicitor_firm_name] = office_code_details['officeName']
        end

        multi_step_form_session[:office_code_search] = nil
      end

      def office_code_details
        ProviderData::ProviderDataClient.new.office_details(multi_step_form_session[:office_code_search])
      end
    end
  end
end
