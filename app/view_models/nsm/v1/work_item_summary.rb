module Nsm
  module V1
    module WorkItemSummary
      def work_item_data
        @work_item_data ||=
          grouped_work_items
          .filter_map do |translated_work_type, work_items_for_type|
            next if skip_work_item?(work_items_for_type.first)

            # TODO: convert this to a time period to enable easy formating of output
            [
              translated_work_type,
              *summed_values(work_items_for_type)
            ]
          end
      end

      private

      def grouped_work_items
        BaseViewModel.build(:work_item, submission, 'work_items')
                     .group_by { |work_item| work_item.work_type.to_s }
      end

      def summed_values(work_items)
        [
          work_items.sum(&:provider_requested_amount_inc_vat),
          work_items.sum(&:original_time_spent),
          work_items.sum(&:caseworker_amount_inc_vat),
          work_items.sum(&:time_spent),
        ]
      end

      # overwrite if you need custom filtering
      # :nocov:
      def skip_work_item?(*)
        false
      end
      # :nocov:
    end
  end
end
