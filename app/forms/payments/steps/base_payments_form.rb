module Payments
  module Steps
    class BasePaymentsForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      include LaaCrimeFormsCommon::Validators
    end
  end
end
