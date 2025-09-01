class SearchForm < SearchResults
  include LaaCrimeFormsCommon::Validators

  Option = Struct.new(:value, :label)
  APPLICATION_TYPES = [
    Option.new('crm4', I18n.t('shared.application_type.crm4')),
    Option.new('crm7', I18n.t('shared.application_type.crm7'))
  ].freeze

  attribute :query, :string
  attribute :submitted_from, :string
  attribute :submitted_to, :string
  attribute :updated_from, :string
  attribute :updated_to, :string
  attribute :status_with_assignment, :string
  attribute :caseworker_id, :string
  attribute :application_type, :string
  attribute :high_value, :boolean

  validate :at_least_one_field_set
  validates :application_type, presence: true
  validates :submitted_from, :submitted_to, :updated_from, :updated_to, is_a_date: true

  def executed?
    @search_response.present?
  end

  def caseworkers
    [show_all] + User.order(:last_name, :first_name).map { Option.new(_1.id, _1.display_name) }
  end

  def claim_values
    [show_all, Option.new(:high_value, I18n.t('search.claim_values.high_value'))]
  end

  def statuses
    [show_all] + %i[
      not_assigned
      in_progress
      provider_updated
      sent_back
      granted
      auto_grant
      part_grant
      rejected
      expired
    ].map { Option.new(_1, I18n.t("search.statuses.#{_1}")) }
  end

  def application_types
    self.class::APPLICATION_TYPES
  end

  private

  def at_least_one_field_set
    fields = [:query, :submitted_from,
              :submitted_to, :updated_from,
              :updated_to, :status_with_assignment,
              :caseworker_id, :high_value]

    field_set = fields.any? do |field|
      send(field).present?
    end

    return if field_set

    noun = application_type.presence || 'generic'
    errors.add(:base, :nothing_specified, value: I18n.t("shared.submission_noun.#{noun}"))
  end

  def conduct_search
    super
  rescue StandardError => e
    Sentry.capture_exception(e)
    errors.add(:base, :search_error)
    nil
  end

  def show_all
    @show_all ||= Option.new('', I18n.t('search.show_all'))
  end
end
