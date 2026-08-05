module Users
  class DevAuthController < Devise::SessionsController
    def new
      skip_authorization
      raise ActionController::RoutingError, 'dev authentication not available' unless FeatureFlags.dev_auth.enabled?

      users = User.includes(:authentication_identities).where(deactivated_at: nil)
      users = users.sort_by { _1.most_recent_authentication_at || Time.zone.at(0) }.reverse
      @emails = users.map(&:email) << OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
    end
  end
end
