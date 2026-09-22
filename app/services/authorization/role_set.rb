module Authorization
  class RoleSet
    include Enumerable

    def self.empty
      new([])
    end

    def initialize(roles)
      @roles = roles.to_a.freeze
    end

    def each(&block)
      roles.each(&block)
    end

    delegate :empty?, to: :roles

    def caseworker?(service = nil)
      role?(Role::CASEWORKER, service)
    end

    def supervisor?(service = nil)
      role?(Role::SUPERVISOR, service)
    end

    def viewer?(service = nil)
      role?(Role::VIEWER, service)
    end

    def access?(service)
      roles.any? { service_match?(_1, service) }
    end

    private

    attr_reader :roles

    def role?(role_type, service)
      roles.any? do |role|
        role.role_type == role_type && (service.nil? || service_match?(role, service))
      end
    end

    def service_match?(role, service)
      role.service.in?([service.to_s, 'all'])
    end
  end
end
