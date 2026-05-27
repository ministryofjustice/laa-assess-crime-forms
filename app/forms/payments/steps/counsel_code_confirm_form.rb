module Payments
  module Steps
    class CounselCodeConfirmForm < BasePaymentsForm
      attribute :confirm_office_code, :boolean

      validates :confirm_office_code, inclusion: { in: [true, false] }

      def save
        return false unless valid?

        if confirm_office_code
          multi_step_form_session[:counsel_office_code] = office_code_details['office']['firmOfficeCode']
          multi_step_form_session[:counsel_firm_name] = office_code_details['firm']['firmName']
        # :nocov:
        else
          false
        end
        # :nocov:

        true
      end

      def searched_code
        multi_step_form_session[:counsel_office_code]
      end

      def office_code_details
        ProviderData::ProviderDataClient.new.office_details(searched_code)
      end
    end
  end
end
