module Auth
  module Strategies
    class AzureAd
      PROVIDER = 'azure_ad'.freeze

      def initialize(auth_hash)
        @auth_hash = auth_hash
      end

      def call
        user = local_user
        return failure(:not_authorized) unless user

        sync_user!(user)
        Result.new(user: user, failure_reason: nil)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        failure(:invalid_azure_identity)
      end

      private

      attr_reader :auth_hash

      def local_user
        identity = AuthenticationIdentity.find_by(provider: PROVIDER, subject: auth_hash.uid)
        user = identity&.user || User.pending_activation.find_by(email: auth_hash.info.email)

        user unless user&.deactivated_at
      end

      def sync_user!(user)
        now = Time.current

        ActiveRecord::Base.transaction do
          user.update!(user_attributes(user, now))
          sync_identity!(user, now)
        end
      end

      def user_attributes(user, now)
        {
          first_name: auth_hash.info.first_name,
          last_name: auth_hash.info.last_name,
          email: auth_hash.info.email,
          auth_subject_id: auth_hash.uid,
          first_auth_at: user.first_auth_at || now,
          last_auth_at: now
        }
      end

      def sync_identity!(user, now)
        identity = user.authentication_identities.find_or_initialize_by(provider: PROVIDER)
        identity.subject = auth_hash.uid
        identity.first_authenticated_at ||= now
        identity.last_authenticated_at = now
        identity.save!
      end

      def failure(reason)
        Result.new(user: nil, failure_reason: reason)
      end
    end
  end
end
