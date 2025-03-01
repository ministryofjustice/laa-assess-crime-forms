# Special form to process each row/record when running the
# remove uplift from all processing.
module Nsm
  module Uplift
    class RemoverForm < BaseAdjustmentForm
      attribute :selected_record

      def save
        process_field(value: 0, field: 'uplift')
      end

      private

      def data_changed
        return if data_has_changed?

        errors.add(:base, :no_change)
      end

      def data_has_changed?
        selected_record['uplift']&.positive?
      end
    end
  end
end
