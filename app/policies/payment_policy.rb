class PaymentPolicy < ApplicationPolicy
  def index?
    service_access?
  end

  def update?
    service_access? || user.viewer?
  end

  private

  def service_access?
    user.nsm_access? || user.pa_access?
  end
end
