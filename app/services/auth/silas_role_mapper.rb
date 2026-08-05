module Auth
  class SilasRoleMapper
    class MissingRoles < StandardError; end
    class UnknownRole < StandardError; end
    class InvalidConfiguration < StandardError; end

    def self.call(raw_roles)
      new(raw_roles).call
    end

    def self.claim_values_for(roles)
      roles.map do |role|
        role_attributes = { role_type: role.role_type, service: role.service }
        role_mappings.key(role_attributes) || raise(UnknownRole, "No SiLAS role mapping for #{role_attributes}")
      end.uniq
    end

    def self.role_mappings
      mapping = JSON.parse(ENV.fetch('SILAS_ROLE_MAPPINGS', '{}'))
      raise InvalidConfiguration, 'SILAS_ROLE_MAPPINGS must be a JSON object' unless mapping.is_a?(Hash)

      mapping.to_h do |claim_value, attributes|
        raise InvalidConfiguration, "Invalid SiLAS role mapping for #{claim_value}" unless attributes.is_a?(Hash)

        role_attributes = attributes.to_h.symbolize_keys.slice(:role_type, :service)

        unless Role::ROLE_TYPES.include?(role_attributes[:role_type]) && Role.services.key?(role_attributes[:service])
          raise InvalidConfiguration, "Invalid SiLAS role mapping for #{claim_value}"
        end

        [claim_value, role_attributes]
      end
    rescue JSON::ParserError => e
      raise InvalidConfiguration, "Invalid SILAS_ROLE_MAPPINGS: #{e.message}"
    end

    def initialize(raw_roles)
      @raw_roles = raw_roles
    end

    def call
      raise MissingRoles if normalised_roles.empty?

      mappings = self.class.role_mappings
      normalised_roles.map do |role|
        mappings.fetch(role) { raise UnknownRole, "Unknown SiLAS role: #{role}" }
      end.uniq
    end

    private

    attr_reader :raw_roles

    def normalised_roles
      roles = case raw_roles
              when Array
                raw_roles
              when String
                raw_roles.split(',')
              else
                []
              end

      raise UnknownRole, 'SiLAS roles must be strings' unless roles.all?(String)

      roles.map(&:strip).compact_blank
    end
  end
end
