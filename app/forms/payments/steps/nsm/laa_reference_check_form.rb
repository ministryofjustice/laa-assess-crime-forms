module Payments
  module Steps
    module Nsm
      class LaaReferenceCheckForm < BasePaymentsForm
        attribute :laa_reference_check, :boolean

        def save
          return false unless valid?

          multi_step_form_session[:laa_reference_check] = laa_reference_check

          true
        rescue StandardError
          errors.add(:base, :sync_error)
          false
        end
      end
    end
  end
end
