class MetabasePolicy < ApplicationPolicy
  def show?
    user.supervisor?
  end
end
