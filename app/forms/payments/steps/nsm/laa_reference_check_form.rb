module Payments
  module Steps
    module Nsm
      class LaaReferenceCheckForm < BasePaymentsForm
        attribute :laa_reference_check, :boolean
        # Due to how Rails handles HTML forms with radio buttons that
        # can be blank, we can't use presence validation here
        validates :laa_reference_check, inclusion: { in: [true, false] }
      end
    end
  end
end
