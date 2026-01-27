module Payments
  class AcCostsSummaryAppealed < AcCostsSummaryAmended
    def heading
      I18n.t('payments.steps.check_your_answers.edit.allowed_costs')
    end
  end
end
