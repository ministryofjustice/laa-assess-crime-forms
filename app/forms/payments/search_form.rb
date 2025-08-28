module Payments
  class SearchForm < SearchResults
    Option = Struct.new(:value, :label)
    CLAIM_TYPES = [
      Option.new('NsmClaim', I18n.t('shared.claim_type.nsm')),
      # Option.new('nsm_supplemental', I18n.t('shared.claim_type.nsm_supplemental')),
      # Option.new('nsm_appeal', I18n.t('shared.claim_type.nsm_appeal')),
      # Option.new('nsm_amendment', I18n.t('shared.claim_type.nsm_amendment')),
      Option.new('AssignedCounselClaim', I18n.t('shared.claim_type.acc')),
      # Option.new('acc_appeal', I18n.t('shared.claim_type.acc_appeal')),
      # Option.new('acc_amendment', I18n.t('shared.claim_type.acc_amendment')),
    ].freeze

    attribute :query, :string
    attribute :claim_type, :string
    attribute :submitted_from, :string
    attribute :submitted_to, :string
    attribute :received_from, :string
    attribute :received_to, :string

    validates :submitted_from, :submitted_to, :received_from, :received_to, is_a_date: true

    def executed?
      @search_response.present?
    end

    def conduct_search
      AppStoreClient.new.search(search_params, :payments).deep_symbolize_keys
    rescue StandardError => e
      Sentry.capture_exception(e)
      errors.add(:base, :search_error)
      nil
    end

    def claim_types
      self.class::CLAIM_TYPES
    end

    def show_all
      @show_all ||= Option.new('', I18n.t('search.show_all'))
    end
  end
end
