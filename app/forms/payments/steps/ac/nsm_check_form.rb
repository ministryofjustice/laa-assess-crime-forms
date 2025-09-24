# :nocov:
module Payments
  module Steps
    module Ac
      class NsmCheckForm < BasePaymentsForm
        attribute :linked_to_nsm, :boolean

        validates :linked_to_nsm, inclusion: { in: [true, false] }
      end
    end
  end
end
# :nocov:
