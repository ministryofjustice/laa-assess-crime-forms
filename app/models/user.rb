class User < ApplicationRecord
  has_many :access_logs, dependent: :destroy

  ROLES = [
    CASEWORKER = 'caseworker'.freeze,
    SUPERVISOR = 'supervisor'.freeze,
    VIEWER = 'viewer'.freeze
  ].freeze
  devise :omniauthable, :timeoutable

  include AuthUpdateable
  include Reauthable

  validates :role, inclusion: { in: ROLES }

  scope :active, -> { where(deactivated_at: nil).where.not(auth_subject_id: nil) }
  scope :pending_activation, -> { where(auth_subject_id: nil, deactivated_at: nil) }

  def display_name
    "#{first_name} #{last_name}"
  end

  def supervisor?
    role == SUPERVISOR
  end

  def viewer?
    role == VIEWER
  end

  def pending_activation?
    auth_subject_id.nil? && first_auth_at.nil?
  end
end
