module Auth
  class SessionContext
    SESSION_KEY = 'auth_provider'.freeze
    LEGACY_PROVIDER = 'azure_ad'.freeze

    def self.bind!(session, callback_provider)
      session[SESSION_KEY] = Provider.normalise_callback_name(callback_provider)
    end

    def initialize(session:, configured_provider: Provider.current)
      @session = session
      @configured_provider = configured_provider
    end

    def valid?
      provider&.name == configured_provider.name
    end

    def provider
      @provider ||= Provider.fetch(session.fetch(SESSION_KEY, LEGACY_PROVIDER))
    rescue Provider::UnknownProvider
      nil
    end

    def role_source
      raise Provider::UnknownProvider, 'Session is not bound to a supported provider' unless provider

      @role_source ||= Authorization::RoleSource.for(provider.role_authority)
    end

    def role_management_editable?
      role_source.editable?
    end

    private

    attr_reader :session, :configured_provider
  end
end
