module Auth
  class Provider
    CONFIGURATIONS = {
      'azure_ad' => {
        role_authority: 'local',
        role_management_editable: true
      },
      'silas' => {
        role_authority: 'silas',
        role_management_editable: false
      }
    }.freeze

    CALLBACK_ALIASES = { 'dev_auth' => 'azure_ad' }.freeze

    class UnknownProvider < StandardError; end

    class << self
      def current
        fetch(ENV.fetch('ASSESS_AUTH_PROVIDER', 'azure_ad'))
      end

      def fetch(name)
        normalised_name = name.to_s
        configuration = CONFIGURATIONS[normalised_name]
        raise UnknownProvider, "Unknown auth provider: #{normalised_name}" unless configuration

        new(name: normalised_name, **configuration)
      end

      def normalise_callback_name(name)
        CALLBACK_ALIASES.fetch(name.to_s, name.to_s)
      end
    end

    attr_reader :name, :role_authority

    def initialize(name:, role_authority:, role_management_editable:)
      @name = name
      @role_authority = role_authority
      @role_management_editable = role_management_editable
    end

    def accepts_callback?(callback_name)
      self.class.normalise_callback_name(callback_name) == name
    end

    def role_management_editable?
      @role_management_editable
    end

    def authorization_path_helper
      :"user_#{name}_omniauth_authorize_path"
    end

    def callback_path_helper
      :"user_#{name}_omniauth_callback_path"
    end
  end
end
