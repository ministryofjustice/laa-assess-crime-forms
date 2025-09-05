module Decisions
  class CustomWrapper < SimpleDelegator
    def any_invalid?(scope, *forms)
      scope.detect { |record| forms.any? { |f| !f.build(record, application:).valid? } }
    end

    def overwrite_to_cya(destination: Decisions::DecisionTree::PAYMENT_START_PAGE, action: :index)
      if application.viewed_steps.include?('check_answers')
        { edit: Decisions::DecisionTree::PAYMENT_CHECK_ANSWERS }
      else
        { action => destination }
      end
    end
  end
end
