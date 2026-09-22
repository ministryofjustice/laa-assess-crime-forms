# A Devise style module to enforce the maximum time that can pass between
# authentications regardless of user activity.
#

require Rails.root.join('app/lib/warden_hooks/reauthable')

module Reauthable
  extend ActiveSupport::Concern

  def auth_expired?(provider)
    return false unless reauthenticate_in

    identity = authentication_identity_for(provider)
    identity.nil? || identity.authentication_expired?
  end

  private

  def reauthenticate_in
    Rails.configuration.x.auth.reauthenticate_in
  end
end
