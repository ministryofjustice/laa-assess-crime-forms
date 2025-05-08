class UsersParams < BaseParamValidator
  attribute :id, :string
  attribute :sort_by, :string
  attribute :sort_direction, :string
  attribute :page, :integer

  validates :sort_by, inclusion: { in: %w[name email role service] },
allow_nil: true
  validates :sort_direction, inclusion: { in: %w[ascending descending] }, allow_nil: true
  validates :page, numericality: { greater_than: 0 }, allow_nil: true
  validates :id, is_a_uuid: true, allow_nil: true
end
