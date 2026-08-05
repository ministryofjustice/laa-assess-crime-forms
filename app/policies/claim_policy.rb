class ClaimPolicy < ApplicationPolicy
  def update?
    service_access? && !record.closed? && record.assigned_user_id == user.id && !user.viewer?(:nsm)
  end

  def unassign?
    service_access? && !record.closed? && record.assigned_user_id.present? && !user.viewer?(:nsm)
  end

  def self_assign?
    service_access? && assign? && !record.closed? && record.assigned_user_id.nil?
  end

  def assign?
    service_access? && !user.viewer?(:nsm)
  end

  def index?
    service_access?
  end

  def show?
    service_access?
  end

  private

  def service_access?
    user.nsm_access?
  end
end
