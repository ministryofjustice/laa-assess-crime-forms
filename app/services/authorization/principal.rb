module Authorization
  class Principal
    attr_reader :user

    delegate :id, to: :user

    def initialize(user:, role_source:)
      @user = user
      @role_source = role_source
    end

    def roles
      @roles ||= role_source.roles_for(user)
    end

    def nsm_access?
      roles.access?(:nsm)
    end

    def pa_access?
      roles.access?(:pa)
    end

    def supervisor?(service = nil)
      roles.supervisor?(service)
    end

    def caseworker?(service = nil)
      roles.caseworker?(service)
    end

    def viewer?(service = nil)
      roles.viewer?(service)
    end

    private

    attr_reader :role_source
  end
end
