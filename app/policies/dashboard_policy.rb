class DashboardPolicy < ApplicationPolicy
  def show?
    user.supervisor?(:pa) && user.supervisor?(:nsm)
  end
end
