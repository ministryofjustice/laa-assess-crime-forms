# :nocov:
module Payments
  module Steps
    module Ac
      class ClaimedCostsForm < BasePaymentsForm
        attribute :claimed_net, :string
        attribute :claimed_vat, :string
      end
    end
  end
end
# :nocov:
