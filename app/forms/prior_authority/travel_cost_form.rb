module PriorAuthority
  class TravelCostForm < BaseAdjustmentForm
    include LaaCrimeFormsCommon::Validators
    include NumericLimits

    attribute :id, :string
    attribute :travel_time, :time_period
    attribute :travel_cost_per_hour, :gbp

    validates :travel_time, presence: true, time_period: { allow_zero: true }
    validate :travel_time_hours_within_limit
    validates :travel_cost_per_hour, presence: true,
              numericality: { greater_than: 0, less_than_or_equal_to: NumericLimits::MAX_FLOAT },
              is_a_number: true

    validates :explanation, presence: true, if: :explanation_required?

    def save
      return false unless valid?

      process_fields

      true
    end

    COMMENT_FIELD = 'travel_adjustment_comment'.freeze

    private

    def process_fields
      process_field(value: travel_time.to_i, field: 'travel_time')
      process_field(value: travel_cost_per_hour.to_s, field: 'travel_cost_per_hour')
    end

    def selected_record
      @selected_record ||= submission.data['quotes'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def travel_time_hours_within_limit
      validate_time_period_max_hours(:travel_time, max_hours: NumericLimits::MAX_INTEGER)
    end

    def data_has_changed?
      travel_time != item.travel_time ||
        travel_cost_per_hour != item.travel_cost_per_hour
    end
  end
end
