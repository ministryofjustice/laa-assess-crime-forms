class PriorAuthorityApplicationPolicy < ApplicationPolicy
  def unassign?
    service_access? && assessable? && record.assigned_user_id.present? && !user.viewer?
  end

  def self_assign?
    service_access? && assign? && assessable? && record.assigned_user_id.nil?
  end

  def update?
    service_access? && assessable? && record.assigned_user_id == user.id && !user.viewer?
  end

  def assign?
    service_access? && !user.viewer?
  end

  def index?
    service_access?
  end

  def show?
    service_access?
  end

  private

  def assessable?
    record.state.in?(PriorAuthorityApplication::ASSESSABLE_STATES)
  end

  def service_access?
    user.pa_access?
  end
end
