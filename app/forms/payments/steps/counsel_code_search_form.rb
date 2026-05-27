module Payments
  module Steps
    class CounselCodeSearchForm < BasePaymentsForm
      attribute :counsel_office_code, :string

      validates :counsel_office_code, presence: true

      def save
        return false unless valid?

        multi_step_form_session[:counsel_office_code] = counsel_office_code
      end
    end
  end
end
