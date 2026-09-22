class AuthenticationIdentity < ApplicationRecord
  PROVIDERS = %w[azure_ad silas].freeze

  belongs_to :user

  validates :provider, inclusion: { in: PROVIDERS }, uniqueness: { scope: :user_id }
  validates :subject, presence: true, uniqueness: { scope: :provider }

  def authentication_expired?
    return true unless last_authenticated_at

    last_authenticated_at < Rails.configuration.x.auth.reauthenticate_in.ago
  end
end
