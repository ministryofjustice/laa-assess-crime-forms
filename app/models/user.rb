class User < ApplicationRecord
  DummyUser = Struct.new(:display_name)
  validates :email, uniqueness: true
  has_many :access_logs, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :silas_roles, dependent: :destroy
  has_many :authentication_identities, dependent: :destroy

  devise :omniauthable, :timeoutable

  include Reauthable

  scope :active, -> { where(deactivated_at: nil).where.associated(:authentication_identities).distinct }
  scope :pending_activation, -> { where(deactivated_at: nil).where.missing(:authentication_identities) }

  def display_name
    "#{first_name} #{last_name}"
  end

  def authentication_identity_for(provider)
    return authentication_identities.detect { _1.provider == provider.to_s } if authentication_identities.loaded?

    authentication_identities.find_by(provider: provider.to_s)
  end

  def pending_activation?
    authentication_identities.empty?
  end

  def most_recent_authentication_at
    return authentication_identities.filter_map(&:last_authenticated_at).max if authentication_identities.loaded?

    authentication_identities.maximum(:last_authenticated_at)
  end

  def self.load(user_id)
    return unless user_id

    find_by(id: user_id) || DummyUser.new(I18n.t('helpers.non_local_caseworker'))
  end
end
