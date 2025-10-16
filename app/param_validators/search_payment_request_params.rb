class SearchPaymentRequestParams < BaseParamValidator
  attribute :id, :string
  attribute :sort_by, :string
  attribute :sort_direction, :string
  attribute :page, :integer
  attribute :current_page, :string
  attribute :payment_id, :string

  validates :sort_by, inclusion: { in: %w[laa_reference firm_name client_last_name request_type submitted_at] },
allow_nil: true
  validates :sort_direction, inclusion: { in: %w[ascending descending] }, allow_nil: true
  validates :page, numericality: { greater_than: 0 }, allow_nil: true
  validates :id, is_a_uuid: true, allow_nil: true
  validates :current_page, inclusion: { in: %w[payment_request claim_details related_payments] }, allow_nil: true
  validates :payment_id, is_a_uuid: true, allow_nil: true
end
