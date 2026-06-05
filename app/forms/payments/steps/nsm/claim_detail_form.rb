module Payments
  module Steps
    module Nsm
      class ClaimDetailForm < BasePaymentsForm
        include NumericLimits

        attribute :date_claim_assessed, :date
        attribute :original_submission_year, :integer
        attribute :original_submission_month, :integer
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
                  :hearing_outcome_code, :matter_type, :court_name,
                  presence: true

        validates :number_of_defendants, :number_of_attendances, presence: true, is_a_number: true,
          numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: NumericLimits::MAX_INTEGER }

        # Due to how Rails handles HTML forms with radio buttons that
        # can be blank, we can't use presence validation here
        validates :youth_court, inclusion: { in: [true, false] }
        validates :stage_reached, inclusion: { in: %w[PROG PROM] }

        validates :ufn, presence: true, ufn: true
        validates :date_completed, :date_claim_assessed,
                  presence: true, multiparam_date: { allow_past: true, allow_future: false }
        validate :submission_date_must_be_present, :submission_date_must_be_valid, :submission_date_must_be_in_past,
                 if: :submission_date_needed?

        def save
          handle_court_details
          handle_original_submission_date

          return false unless valid?

          attributes.except('court_name_suggestion').each do |k, v|
            multi_step_form_session[k.to_sym] = v
          end

          true
        end

        def submission_date_needed?
          multi_step_form_session[:request_type].in?(
            %w[non_standard_mag_supplemental non_standard_mag_appeal non_standard_mag_amendment]
          )
        end

        def original_submission_date
          Date.new(original_submission_year, original_submission_month, 1) if valid_date?
        end

        private

        # rubocop:disable Metrics/AbcSize
        def handle_court_details
          # We need to check if the court name suggestion matches an existing court and
          # if so, use the existing court's name and id instead of the custom values
          court = LaaCrimeFormsCommon::Court.all.find { |c| attributes['court_name_suggestion']&.downcase == c.short_name.downcase }
          if court
            self.court_id = court.id
            self.court_name = court.short_name
          elsif attributes['court_name_suggestion'].present?
            self.court_id = I18n.t('laa_crime_forms_common.shared.custom')
            self.court_name = attributes['court_name_suggestion']
          else
            self.court_id = ''
            self.court_name = ''
          end
        end
        # rubocop:enable Metrics/AbcSize

        def handle_original_submission_date
          return if submission_date_needed?

          self.original_submission_year = Date.current.year
          self.original_submission_month = Date.current.month
        end

        def valid_date?
          Date.valid_date?(original_submission_year, original_submission_month, 1)
        end

        def submission_date_must_be_present
          return unless original_submission_year.blank? || original_submission_month.blank?

          errors.add(:original_submission_date, :blank)
        end

        def submission_date_must_be_valid
          errors.add(:original_submission_date, :invalid) unless valid_date?
        end

        def submission_date_must_be_in_past
          return unless original_submission_date.present? && original_submission_date > first_day_of_current_month

          errors.add(:original_submission_date, :must_be_in_past)
        end

        def first_day_of_current_month
          Date.new(Date.current.year, Date.current.month, 1)
        end
      end
    end
  end
end
