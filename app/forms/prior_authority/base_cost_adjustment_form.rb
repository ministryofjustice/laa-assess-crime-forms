module PriorAuthority
  class BaseCostAdjustmentForm < BaseAdjustmentForm
    include LaaCrimeFormsCommon::Validators
    include NumericLimits

    PER_ITEM = 'per_item'.freeze
    PER_HOUR = 'per_hour'.freeze

    attribute :id, :string

    attribute :items, :fully_validatable_integer
    attribute :cost_per_item, :gbp
    attribute :period, :time_period
    attribute :cost_per_hour, :gbp

    with_options if: :per_item? do
      validates :items, item_type_dependant: true
      validates :cost_per_item, cost_item_type_dependant: true
      validate :items_within_limit
      validate :cost_per_item_within_limit
    end

    with_options if: :per_hour? do
      validates :period, presence: true, time_period: { allow_zero: true }
      validate :period_hours_within_limit
      validates :cost_per_hour, presence: true,
                numericality: { greater_than: 0, less_than_or_equal_to: NumericLimits::MAX_FLOAT },
                is_a_number: true
    end

    validates :explanation, presence: true, if: :explanation_required?

    def save
      return false unless valid?

      process_fields

      true
    end

    # :nocov:
    def per_item?
      raise 'Implement in subclass'
    end
    # :nocov:

    # :nocov:
    def per_hour?
      raise 'Implement in subclass'
    end
    # :nocov:

    private

    # :nocov:
    def process_fields
      raise 'Implement in subclass'
    end
    # :nocov:

    def period_hours_within_limit
      validate_time_period_max_hours(:period, max_hours: NumericLimits::MAX_INTEGER)
    end

    def items_within_limit
      # :nocov:
      return if items.blank? || !items.is_a?(Numeric)
      # :nocov:

      errors.add(:items, :less_than_or_equal_to, count: MAX_INTEGER) if items > MAX_INTEGER
    end

    def cost_per_item_within_limit
      # :nocov:
      return if cost_per_item.blank? || !cost_per_item.is_a?(Numeric)
      # :nocov:

      errors.add(:cost_per_item, :less_than_or_equal_to, count: MAX_FLOAT) if cost_per_item > MAX_FLOAT
    end

    def data_has_changed?
      if per_hour?
        period != item.period || cost_per_hour != item.cost_per_hour
      else
        items != item.items || cost_per_item != item.cost_per_item
      end
    end
  end
end
