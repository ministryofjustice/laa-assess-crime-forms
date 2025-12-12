module Payments
  module Steps
    class OfficeCodeSearchForm < BasePaymentsForm
      attribute :solicitor_office_code, :string

      validates :solicitor_office_code, office_code: true, presence: true

      def save
        return false unless valid?

        multi_step_form_session[:solicitor_office_code] = solicitor_office_code
      end
    end
  end
end
