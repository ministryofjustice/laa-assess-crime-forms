module Payments
  module Steps
    class OfficeCodeConfirmForm < BasePaymentsForm
      attribute :confirm_office_code, :boolean

      validates :confirm_office_code, inclusion: { in: [true, false] }

      def save
        return false unless valid?

        if confirm_office_code
          multi_step_form_session[:solicitor_office_code] = office_code_details['firmOfficeCode']
          multi_step_form_session[:solicitor_firm_name] = office_code_details['officeName']
        else
          reset_office_details
        end

        true
      end

      def searched_code
        multi_step_form_session[:solicitor_office_code]
      end

      def office_code_details
        ProviderData::ProviderDataClient.new.office_details(searched_code)
      end

      private

      def reset_office_details
        multi_step_form_session[:solicitor_office_code] = nil
        multi_step_form_session[:solicitor_firm_name] = nil
      end
    end
  end
end
