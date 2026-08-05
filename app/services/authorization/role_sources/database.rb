module Authorization
  module RoleSources
    class Database
      attr_reader :preload_association

      def initialize(preload_association:)
        @preload_association = preload_association
      end

      def roles_for(user)
        RoleSet.new(role_records_for(user))
      end

      private

      def role_records_for(user)
        user.public_send(preload_association).to_a
      end
    end
  end
end
