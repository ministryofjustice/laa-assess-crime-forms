# :nocov:
module Payments
  module Steps
    module Ac
      class AllowedCostsForm < BasePaymentsForm
        attribute :allowed_net, :string
        attribute :allowed_vat, :string
      end
    end
  end
end
# :nocov:
