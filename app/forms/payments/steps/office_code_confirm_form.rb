module Payments
  module Steps
    class OfficeCodeConfirmForm < BasePaymentsForm
      attribute :confirm_office_code, :boolean

      validates :confirm_office_code, inclusion: { in: [true, false] }

      def save
        return false unless valid?

        details = office_code_details

        if confirm_office_code
          multi_step_form_session[:solicitor_office_code] = details['firmOfficeCode']
          multi_step_form_session[:solicitor_firm_name] = details.dig('firm', 'firmName')
        # :nocov:
        else
          false
        end
        # :nocov:

        true
      end

      def searched_code
        multi_step_form_session[:solicitor_office_code]
      end

      def solicitor_firm_name
        multi_step_form_session[:solicitor_firm_name]
      end

      def office_code_details
        return nil if searched_code.blank? || solicitor_firm_name.blank?

        {
          'firmOfficeCode' => searched_code,
          'firm' => { 'firmName' => solicitor_firm_name }
        }
      end
    end
  end
end
