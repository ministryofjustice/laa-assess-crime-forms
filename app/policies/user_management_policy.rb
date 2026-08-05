class UserManagementPolicy < ApplicationPolicy
  def show?
    user.supervisor?(:all)
  end
end
