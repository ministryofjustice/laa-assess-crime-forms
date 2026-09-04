class SilasRole < ApplicationRecord
  belongs_to :user

  validates :role_type, inclusion: { in: Role::ROLE_TYPES }

  scope :caseworker, -> { where(role_type: Role::CASEWORKER) }
  scope :supervisor, -> { where(role_type: Role::SUPERVISOR) }
  scope :viewer, -> { where(role_type: Role::VIEWER) }

  enum :service, Role.services, prefix: true

  scope :pa_access, -> { where(service: %w[pa all]) }
  scope :nsm_access, -> { where(service: %w[nsm all]) }
end
