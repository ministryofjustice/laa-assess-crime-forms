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
    user.roles.supervisor.exists?
  end

  def caseworker_payments_role?
    user.roles.exists?(role_type: Role::CASEWORKER, service: %w[nsm all])
  end
end
