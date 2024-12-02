module Nsm
  class YouthCourtFeeAdjustmentForm < BaseAdjustmentForm
    COMMENT_FIELD = 'youth_court_fee_adjustment_comment'.freeze
    LINKED_CLASS = V1::YouthCourtFee

    attribute :remove_youth_court_fee
    attribute :youth_court_fee_adjustment_comment

    def save
      return false unless valid?

      remove_bool = ActiveModel::Type::Boolean.new.cast(remove_youth_court_fee)

      # remove
      # "youth_court_fee_adjustment_comment":,
      # and "include_youth_court_fee_original":
      # if remove_youth_court_fee is false/No, do not remove fee
      # check flipping of remove_youth_court_fee

      process_field(value: !remove_bool, field: 'include_youth_court_fee')

      true
    end

    private

    def explanation_required?
      remove_youth_court_fee == 'true'
    end

    def adjustment_comment
      youth_court_fee_adjustment_comment
    end

    def selected_record
      @selected_record ||= submission.data
    end

    def data_has_changed?
      remove_youth_court_fee != item.include_youth_court_fee
    end

    def linked
      {
        type: self.class::LINKED_CLASS::LINKED_TYPE
      }
    end
  end
end
