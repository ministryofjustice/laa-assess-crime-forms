module OmniAuth
  module Strategies
    class DevAuth
      # IMPORTANT NOTE: This OmniAuth strategy is intended for local
      # development purposes only.
      #
      # During the callback phase, this strategy searches for a user
      # with the given email address in the local database. If a user
      # with a matching email address is found and is authorised,
      # the strategy constructs an auth hash based on the user's
      # information in the database.
      #
      # In cases where the strategy is unable to find an authorised
      # user with the given email address, it generates a subject and
      # guesses the user's first and last name based on the email address.

      include OmniAuth::Strategy

      NO_AUTH_EMAIL = 'Not.Authorised@example.com'.freeze

      uid { authentication_subject }
      credentials { { expires_in: 12.hours } }
      info { { email:, first_name:, last_name: } }
      extra { silas? ? { raw_info: silas_claims } : {} }

      private

      def email
        @email ||= request.params.fetch('email')
      end

      def user
        return @user if defined?(@user)

        @user = User.find_by(email:)
      end

      def authentication_subject
        user&.authentication_identity_for(provider_name)&.subject || SecureRandom.uuid
      end

      def first_name
        user&.first_name || names_from_email.first
      end

      def last_name
        user&.last_name || names_from_email.last
      end

      def names_from_email
        @names_from_email ||= email.split('@').first.split('.')
      end

      def silas?
        options.name.to_s == 'silas'
      end

      def provider_name
        silas? ? 'silas' : 'azure_ad'
      end

      def silas_claims
        {
          'USER_NAME' => user&.authentication_identity_for('silas')&.subject,
          'USER_EMAIL' => email,
          'LAA_APP_ROLES' => Auth::SilasRoleMapper.claim_values_for(simulated_silas_roles)
        }
      end

      def simulated_silas_roles
        return [] unless user

        user.silas_roles
      end
    end
  end
end
