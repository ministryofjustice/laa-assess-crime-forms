module Payments
  module Steps
    module Ac
      class AllowedCostsForm < BasePaymentsForm
        attribute :allowed_net, :string
        attribute :allowed_vat, :string

        def save
          return false unless valid?

          attributes.each do |k, v|
            multi_step_form_session[k.to_sym] = v
          end

          true
        rescue StandardError
          errors.add(:base, :sync_error)
          false
        end
      end
    end
  end
end
