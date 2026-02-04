module Payments
  module Steps
    module Ac
      class ClaimDetailForm < BasePaymentsForm
        attribute :date_received, :date
        attribute :ufn, :string
        attribute :defendant_last_name, :string
        attribute :counsel_office_code, :string
        attribute :counsel_firm_name, :string

        validates :counsel_firm_name, :defendant_last_name, presence: true
        validates :counsel_office_code, presence: true, office_code: true
        validates :ufn, presence: true, ufn: true
        validates :date_received,
                  presence: true, multiparam_date: { allow_past: true, allow_future: false }

        def save
          if linked_claim?
            self.ufn = multi_step_form_session[:ufn]
            self.defendant_last_name = multi_step_form_session[:defendant_last_name]
          end

          super
        end

        def linked_claim?
          multi_step_form_session[:nsm_claim_id].present?
        end
      end
    end
  end
end
