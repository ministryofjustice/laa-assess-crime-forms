module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    before_action :skip_authorization

    def azure_ad
      authenticate_from_omniauth
    end

    def silas
      authenticate_from_omniauth
    end

    # :nocov:
    def failure
      throw(:warden, recall: 'Errors#forbidden', message: :forbidden)
    end

    # Override the #passthru action. It is used when a GET request is made
    # to the user auth url. Ideally the GET route would not be added by Devise.
    # The fix for this is in Devise but awaiting release:
    # https://github.com/heartcombo/devise/pull/5508
    def passthru
      redirect_to new_user_session_path
    end
    # :nocov:

    private

    def authenticate_from_omniauth
      result = Auth::UserAuthenticator.call(request.env['omniauth.auth'])

      if result.success?
        Auth::SessionContext.bind!(session, request.env['omniauth.auth'].provider)
        sign_in_and_redirect result.user, event: :authentication
      else
        Rails.logger.warn("Authentication failed: #{result.failure_reason}")
        throw(:warden, recall: 'Errors#forbidden', message: :forbidden)
      end
    end
  end
end
