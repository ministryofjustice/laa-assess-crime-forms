module Payments
  module Steps
    module Nsm
      class ClaimDetailForm < BasePaymentsForm
        include NumericLimits

        attribute :date_received, :date
        attribute :ufn, :string
        attribute :stage_reached, :string
        attribute :defendant_first_name, :string
        attribute :defendant_last_name, :string
        attribute :number_of_defendants, :integer
        attribute :number_of_attendances, :integer
        attribute :hearing_outcome_code, :string
        attribute :matter_type, :string
        attribute :court_id, :string
        attribute :court_name, :string
        attribute :court_name_suggestion, :string
        attribute :youth_court, :boolean
        attribute :date_completed, :date

        validates :defendant_first_name, :defendant_last_name,
                  :hearing_outcome_code, :matter_type, :court_name_suggestion,
                  presence: true

        validates :number_of_defendants, :number_of_attendances, presence: true, is_a_number: true,
          numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: NumericLimits::MAX_INTEGER }

        # Due to how Rails handles HTML forms with radio buttons that
        # can be blank, we can't use presence validation here
        validates :youth_court, inclusion: { in: [true, false] }
        validates :stage_reached, inclusion: { in: %w[PROG PROM] }

        validates :ufn, presence: true, ufn: true
        validates :date_completed, :date_received,
                  presence: true, multiparam_date: { allow_past: true, allow_future: false }

        # rubocop:disable Metrics/AbcSize
        def save
          # We need to check if the court name suggestion matches an existing court and
          # if so, use the existing court's name and id instead of the custom values
          court = LaaCrimeFormsCommon::Court.all.find { |c| attributes['court_name_suggestion']&.downcase == c.short_name.downcase }
          if court
            self.court_id = court.id
            self.court_name = court.short_name
          else
            self.court_id = 'custom'
            self.court_name = attributes['court_name_suggestion']
          end

          return false unless valid?

          attributes.each do |k, v|
            multi_step_form_session[k.to_sym] = v
          end

          true
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
