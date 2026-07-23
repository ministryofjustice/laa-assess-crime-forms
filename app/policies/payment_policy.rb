class PaymentPolicy < ApplicationPolicy
  def show?
    permitted?
  end

  def index?
    permitted?
  end

  def update?
    permitted?
  end

  private

  def permitted?
    user.supervisor? || (user.caseworker? && user.nsm_access?)
  end
end
