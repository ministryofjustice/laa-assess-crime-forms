module Users
  class SessionsController < Devise::SessionsController
    before_action :skip_authorization

    def destroy
      session.delete(Auth::SessionContext::SESSION_KEY)
      super
    end
  end
end
