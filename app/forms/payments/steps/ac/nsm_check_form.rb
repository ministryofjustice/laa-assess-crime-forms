module Payments
  module Steps
    module Ac
      class NsmCheckForm < BasePaymentsForm
        attribute :linked_to_nsm, :boolean

        validates :linked_to_nsm, presence: true

        def save
          return false unless valid?

          true
        rescue StandardError
          errors.add(:base, :sync_error)
          false
        end
      end
    end
  end
end
