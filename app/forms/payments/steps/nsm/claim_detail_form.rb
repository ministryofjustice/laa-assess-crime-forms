module Payments
  module Steps
    module Nsm
      class ClaimDetailForm < BasePaymentsForm
        attribute :date_received, :date
        attribute :ufn, :string
        attribute :stage_reached, :string
        attribute :defendant_first_name, :string
        attribute :defendant_last_name, :string
        attribute :number_of_defendants, :integer
        attribute :number_of_attendances, :integer
        attribute :hearing_outcome_code, :string
        attribute :matter_type, :string
        attribute :court, :string
        attribute :youth_court, :boolean
        attribute :date_completed, :date

        validates :defendant_first_name, :defendant_last_name,
                  :hearing_outcome_code, :matter_type, :court,
                  presence: true

        validates :number_of_defendants, :number_of_attendances, presence: true, is_a_number: true,
          numericality: { only_integer: true, greater_than_or_equal_to: 0 }

        # Due to how Rails handles HTML forms with radio buttons that
        # can be blank, we can't use presence validation here
        validates :youth_court, inclusion: { in: [true, false] }
        validates :stage_reached, inclusion: { in: %w[PROG PROM] }

        validates :ufn, presence: true, ufn: true
        validates :date_completed, :date_received,
                  presence: true, multiparam_date: { allow_past: true, allow_future: false }
      end
    end
  end
end
