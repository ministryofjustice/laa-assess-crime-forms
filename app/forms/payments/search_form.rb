module Payments
  class SearchForm < SearchResults
    include LaaCrimeFormsCommon::Validators

    Option = Struct.new(:value, :label)
    REQUEST_TYPES = [
      Option.new('non_standard_magistrate', I18n.t('shared.payment_type.non_standard_magistrate')),
      Option.new('non_standard_mag_supplemental', I18n.t('shared.payment_type.non_standard_mag_supplemental')),
      Option.new('non_standard_mag_appeal', I18n.t('shared.payment_type.non_standard_mag_appeal')),
      Option.new('non_standard_mag_amendment', I18n.t('shared.payment_type.non_standard_mag_amendment')),
      Option.new('assigned_counsel', I18n.t('shared.payment_type.assigned_counsel')),
      Option.new('assigned_counsel_appeal', I18n.t('shared.payment_type.assigned_counsel_appeal')),
      Option.new('assigned_counsel_amendment', I18n.t('shared.payment_type.assigned_counsel_amendment')),
    ].freeze

    attribute :query, :string
    attribute :request_type, :string
    attribute :submitted_from, :string
    attribute :submitted_to, :string
    attribute :received_from, :string
    attribute :received_to, :string
    attribute :submission_id, :string

    validates :submitted_from, :submitted_to, :received_from, :received_to, is_a_date: true

    def executed?
      @search_response.present?
    end

    def request_types
      [show_all] + self.class::REQUEST_TYPES
    end

    def show_all
      @show_all ||= Option.new('', I18n.t('search.show_all'))
    end
  end
end
