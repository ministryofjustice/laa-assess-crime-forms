module Auth
  module Strategies
    class Silas
      PROVIDER = 'silas'.freeze

      def initialize(auth_hash)
        @auth_hash = auth_hash
      end

      def call
        claim_failure = validate_identity_claims
        return claim_failure if claim_failure

        mapped_roles = SilasRoleMapper.call(raw_roles)
        user = local_user

        return failure(:unknown_silas_user) unless user
        return failure(:user_deactivated) if user.deactivated_at.present?

        sync_user!(user, mapped_roles)

        Result.new(user: user, failure_reason: nil)
      rescue SilasRoleMapper::MissingRoles, SilasRoleMapper::UnknownRole, SilasRoleMapper::InvalidConfiguration
        failure(:invalid_silas_roles)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        failure(:invalid_silas_identity)
      end

      private

      attr_reader :auth_hash

      def validate_identity_claims
        return failure(:missing_silas_user_name) if silas_user_name.blank?
        return failure(:missing_silas_email) if silas_email.blank?
        return failure(:invalid_silas_user_name) unless silas_user_name.is_a?(String)

        failure(:invalid_silas_email) unless valid_silas_email?
      end

      def sync_user!(user, mapped_roles)
        now = Time.current

        ActiveRecord::Base.transaction do
          identity = user.authentication_identities.find_or_initialize_by(provider: PROVIDER)
          identity.subject = silas_user_name
          user.assign_attributes(user_attributes(user, now))
          user.save!

          user.silas_roles.delete_all
          mapped_roles.each { user.silas_roles.create!(_1) }

          identity.update!(
            first_authenticated_at: identity.first_authenticated_at || now,
            last_authenticated_at: now,
            roles_synced_at: now
          )
        end
      end

      def user_attributes(user, now)
        {
          email: silas_email,
          first_name: auth_hash.info.first_name.presence || user.first_name.presence || silas_user_name,
          last_name: auth_hash.info.last_name.presence || user.last_name.presence || '',
          silas_user_name: silas_user_name,
          first_auth_at: user.first_auth_at || now,
          last_auth_at: now,
          silas_roles_last_synced_at: now
        }
      end

      def local_user
        identity = AuthenticationIdentity.find_by(provider: PROVIDER, subject: silas_user_name)
        return identity.user if identity

        user = User.find_by(email: silas_email)
        return unless user
        return if user.authentication_identity_for(PROVIDER)

        user
      end

      def silas_user_name
        raw_info['USER_NAME']
      end

      def raw_roles
        raw_info['LAA_APP_ROLES']
      end

      def silas_email
        raw_info['USER_EMAIL']
      end

      def valid_silas_email?
        silas_email.is_a?(String) && silas_email.match?(URI::MailTo::EMAIL_REGEXP)
      end

      def raw_info
        value = auth_hash.dig(:extra, :raw_info)

        @raw_info ||= value.is_a?(Hash) ? value.with_indifferent_access : {}.with_indifferent_access
      end

      def failure(reason)
        Result.new(user: nil, failure_reason: reason)
      end
    end
  end
end
