module Payments
  module Steps
    module Nsm
      class LaaReferenceCheckForm < BasePaymentsForm
        attribute :laa_reference_check, :boolean
        validates :laa_reference_check, inclusion: { in: [true, false] }
      end
    end
  end
end
