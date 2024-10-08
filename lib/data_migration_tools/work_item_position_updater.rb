module DataMigrationTools
  class WorkItemPositionUpdater
    def initialize(submission)
      @submission = submission
    end

    def call
      work_items ||= @submission.data['work_items']
      return unless work_items

      work_items.each_with_index do |work_item, idx|
        position = work_item_position(work_item)

        @submission.data['work_items'][idx]['position'] = position
      end

      @submission.save!(touch: false)
    rescue StandardError => e
      Rails.logger.warn "Encountered error updating work item position for submission with id \"#{@submission.id}\"\n" \
                        "\t error: #{e}"
    end

    private

    def work_item_position(work_item)
      sorted_work_item_ids.index(work_item['id']) + 1
    end

    def sorted_work_item_ids
      @sorted_work_item_ids ||= work_items.sort_by do |workitem|
        [
          workitem['completed_on'].to_date || Time.zone.local(2000, 1, 1).to_date,
          workitem['work_type']['value'] || '',
        ]
      end.pluck('id')
    end

    def work_items
      @submission.data['work_items']
    end
  end
end
