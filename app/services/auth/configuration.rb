module Auth
  class Configuration
    REQUIRED_SILAS_ENV = %w[
      SILAS_ENTRA_CLIENT_ID
      SILAS_ENTRA_CLIENT_SECRET
      SILAS_ENTRA_REDIRECT_URI
      SILAS_ENTRA_TENANT_ID
    ].freeze

    class InvalidConfiguration < StandardError; end

    def self.validate!(provider: Provider.current)
      return true unless provider.name == 'silas'

      if FeatureFlags.dev_auth.disabled?
        missing = REQUIRED_SILAS_ENV.select { ENV.fetch(_1, nil).blank? }
        raise InvalidConfiguration, "Missing SiLAS configuration: #{missing.join(', ')}" if missing.any?
      end

      mappings = SilasRoleMapper.role_mappings
      raise InvalidConfiguration, 'SILAS_ROLE_MAPPINGS must define at least one role' if mappings.empty?

      true
    rescue SilasRoleMapper::InvalidConfiguration => e
      raise InvalidConfiguration, e.message
    end
  end
end
