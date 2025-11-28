# :nocov:
module Payments
  module Steps
    module Ac
      class ClaimDetailForm < BasePaymentsForm
        attribute :date_received, :date
        attribute :counsel_office_code, :string
        attribute :counsel_office_name, :string

        validates :counsel_office_code, :counsel_office_name, presence: true
        validates :date_received,
                  presence: true, multiparam_date: { allow_past: true, allow_future: false }
      end
    end
  end
end
# :nocov:
