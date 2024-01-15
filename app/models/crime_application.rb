class CrimeApplication < ApplicationRecord
  APPLICATION_TYPES = {
    non_standard_magistrates_payment: 'crm7',
    prior_authority: 'crm4',
  }.freeze

  has_many :events, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :current_version, numericality: { only_integer: true, greater_than: 0 }
  validates :application_type, inclusion: { in: APPLICATION_TYPES.values }

  # TODO: When prior authority states are defined, stop referring to specifically NSM states here
  scope :pending_decision, -> { where.not(state: NonStandardMagistratesPayment::MakeDecisionForm::STATES) }
  scope :decision_made, -> { where(state: NonStandardMagistratesPayment::MakeDecisionForm::STATES) }

  scope :pending_and_assigned_to, lambda { |user|
    pending_decision
      .joins(:assignments)
      .where(assignments: { user_id: user.id })
  }
  scope :unassigned, lambda { |user|
    pending_decision
      .where.missing(:assignments)
      .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:crime_application_id))
      .order(:created_at)
  }
end
