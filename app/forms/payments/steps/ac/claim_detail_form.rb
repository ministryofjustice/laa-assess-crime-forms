module Payments
  module Steps
    class ClaimDetailForm < BasePaymentsForm
      attribute :date_received, :date
      attribute :office_code, :string
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

      validates :stage_reached, :defendant_first_name, :defendant_last_name,
                :hearing_outcome_code, :matter_type, :court, :youth_court,
                presence: true

      validates :number_of_defendants, :number_of_attendances, presence: true, is_a_number: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      validates :ufn, presence: true, ufn: true
      validates :office_code, presence: true
      validates :date_completed, :date_received,
                presence: true, multiparam_date: { allow_past: true, allow_future: false }
    end
  end
end
