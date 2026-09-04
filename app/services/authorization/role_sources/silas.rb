module Authorization
  module RoleSources
    class Silas < Database
      def initialize
        super(preload_association: :silas_roles)
      end

      def roles_for(user)
        return RoleSet.empty unless fresh_snapshot?(user)

        super
      end

      def editable?
        false
      end

      def display_name
        'SiLAS'
      end

      private

      def fresh_snapshot?(user)
        identity = user.authentication_identity_for('silas')
        return false unless identity&.roles_synced_at

        identity.roles_synced_at >= Rails.configuration.x.auth.reauthenticate_in.ago
      end
    end
  end
end
