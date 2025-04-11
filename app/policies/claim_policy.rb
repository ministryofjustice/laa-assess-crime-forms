class ClaimPolicy < ApplicationPolicy
  def update?
    service_access? && !record.closed? && record.assigned_user_id == user.id
  end

  def unassign?
    service_access? && !record.closed? && record.assigned_user_id.present? && !user.viewer?
  end

  def self_assign?
    service_access? && assign? && !record.closed? && record.assigned_user_id.nil?
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

  def service_access?
    user.roles.nsm_access.any?
  end
end
