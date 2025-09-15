module Payments
  module Steps
    module Ac
      class ClaimedCostsForm < BasePaymentsForm
        attribute :claimed_net, :string
        attribute :claimed_vat, :string

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
