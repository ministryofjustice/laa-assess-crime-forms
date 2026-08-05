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
    supervisor_role? || caseworker_payments_role?
  end

  def supervisor_role?
    user.supervisor?
  end

  def caseworker_payments_role?
    user.caseworker?(:nsm)
  end
end
