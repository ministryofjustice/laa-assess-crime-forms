module WardenHooks
  # Each time a user is set, check to see if the time allowed between
  # authentications has been exceded. If it has, the user is signed out.
  #
  module Reauthable
    # rubocop:disable Lint/NonLocalExitFromIterator
    Warden::Manager.after_set_user do |user, warden, options|
      scope = options[:scope]

      # :nocov:
      return unless user && warden.authenticated?(scope)
      # :nocov:

      proxy = Devise::Hooks::Proxy.new(warden)
      auth_context = Auth::SessionContext.new(session: warden.request.session)

      message = if !auth_context.valid?
                  warden.request.session.delete(Auth::SessionContext::SESSION_KEY)
                  :auth_provider_changed
                elsif user.auth_expired?(auth_context.provider.name)
                  :reauthenticate
                end

      if message
        Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)

        throw :warden, scope:, message:
      end
    end
    # rubocop:enable Lint/NonLocalExitFromIterator
  end
end
