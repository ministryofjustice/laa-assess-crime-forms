module Payments
  module Steps
    class LaaReferenceForm < BasePaymentsForm
      attribute :laa_reference, :string
      validates :laa_reference, presence: true
    end
  end
end
