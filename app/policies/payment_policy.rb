class PaymentPolicy < ApplicationPolicy
  def show?
    service_access? && user_access?
  end

  def index?
    service_access? && user_access?
  end

  private

  def service_access?
    user.nsm_access? || user.pa_access?
  end

  def user_access?
    user.caseworker? || user.supervisor?
  end
end
