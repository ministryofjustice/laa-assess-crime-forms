module Nsm
  class AllAdjustmentsDeleter < AdjustmentDeleterBase
    attr_reader :params, :current_user, :submission, :comment

    def initialize(params, adjustment_type, current_user, submission)
      super
      @comment = params[:comment]
    end

    def call
      delete_work_item_adjustments if work_items
      delete_letters_and_calls_adjustments if letters_and_calls
      delete_disbursement_adjustments if disbursements
      delete_youth_court_fee_adjustment if youth_court_fee_adjustment_comment
      ::Event::DeleteAdjustments.build(submission:, comment:, current_user:)
    end

    def delete_work_item_adjustments
      revert_fields = %w[uplift work_type time_spent]
      work_items.each do |work_item|
        revert_fields.each do |field|
          revert(work_item, field)
        end
        work_item.delete('adjustment_comment')
      end
    end

    def delete_letters_and_calls_adjustments
      revert_fields = %w[uplift count]
      letters_and_calls.each do |letter_or_call|
        revert_fields.each do |field|
          revert(letter_or_call, field)
        end
        letter_or_call.delete('adjustment_comment')
      end
    end

    def delete_disbursement_adjustments
      revert_fields = %w[total_cost vat_amount total_cost_without_vat]
      disbursements.each do |disbursement|
        revert_fields.each do |field|
          revert(disbursement, field)
        end
        disbursement.delete('adjustment_comment')
      end
    end

    def delete_youth_court_fee_adjustment
      revert(submission.data, 'include_youth_court_fee')
      submission.data.delete('youth_court_fee_adjustment_comment')
    end

    def youth_court_fee_adjustment_comment
      submission.data['youth_court_fee_adjustment_comment']
    end

    def letters_and_calls
      @letters_and_calls ||= submission.data['letters_and_calls'].filter { _1['adjustment_comment'] }
    end

    def disbursements
      @disbursements ||= submission.data['disbursements'].filter { _1['adjustment_comment'] }
    end

    def work_items
      @work_items ||= submission.data['work_items'].filter { _1['adjustment_comment'] }
    end
  end
end
