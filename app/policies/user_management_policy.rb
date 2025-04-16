class UserManagementPolicy < ApplicationPolicy
  def show?
    user.supervisor?
  end
end
