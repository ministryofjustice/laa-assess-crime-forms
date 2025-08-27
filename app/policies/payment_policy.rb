class PaymentPolicy < ApplicationPolicy
  def index?
    service_access?
  end

  private

  def service_access?
    user.nsm_access? || user.pa_access?
  end
end
