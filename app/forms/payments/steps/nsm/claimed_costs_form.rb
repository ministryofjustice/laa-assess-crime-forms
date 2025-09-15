module Payments
  module Steps
    module Nsm
      class ClaimedCostsForm < BasePaymentsForm
        attribute :profit_costs, :string
        attribute :disbursement_costs, :string
        attribute :travel_costs, :string
        attribute :waiting_costs, :string

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
