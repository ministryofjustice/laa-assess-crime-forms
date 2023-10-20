class LettersCallsForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :id
  attribute :type, :string
  attribute :uplift, :string
  attribute :count, :integer
  attribute :explanation, :string
  attribute :current_user
  attribute :item # used to detect changes in data

  validates :claim, presence: true
  validates :type, inclusion: { in: %w[letters calls] }
  validates :uplift, inclusion: { in: %w[yes no] }, if: -> { item.uplift? }
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :explanation, presence: true, if: :data_has_changed?
  validate :data_changed

  # overwrite uplift setter to allow value to be passed as either string (form)
  # or integer (initial setup) value
  def uplift=(val)
    case val
    when String then super
    when nil then nil
    else
      super(val.positive? ? 'no' : 'yes')
    end
  end

  def save
    return false unless valid?
    Claim.transaction do
      process_field(value: count, field: 'count')
      process_field(value: new_uplift, field: 'uplift')

      version.save
    end

    true
  rescue StandardError
    false
  end

  def claim
    Claim.find_by(id:)
  end

  private

  def selected_record
    @selected_record ||= version.data['letters_and_calls'].detect do |row|
      row.dig('type', 'value') == type
    end
  end

  def new_uplift
    uplift == 'yes' ? 0 : item.provider_requested_uplift
  end

  def process_field(value:, field:)
    return if selected_record[field] == value

    # does this belong in the Event object as that is where it is
    # created for everything else? as that would require passing a
    # lot of varibles across....
    details = {
      field: field,
      from: selected_record[field],
      to: value,
      change: value - selected_record[field],
      comment: explanation
    }
    linked = { type: }

    selected_record[field] = value
    Event::Edit.build(claim:, details:, linked:, current_user:)
  end

  def data_changed
    return if data_has_changed?

    errors.add(:base, :no_change)
  end

  # we need the item object to
  def data_has_changed?
    # change to count || uplift and uplift has changed
    count != item.count || (item.uplift? && item.uplift.zero? == (uplift == 'no'))
  end

  def version
    @version ||= claim.current_version_record
  end
end
