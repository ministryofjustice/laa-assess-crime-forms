module Payments
  module Steps
    class BaseController < ::Steps::BaseStepController
      before_action :authorized

      layout 'payments'

      # def subsequent_steps
      #   Decisions::OrderedSteps.payment_after(controller_name)
      # end

      def decision_tree_class
        Decisions::DecisionTree
      end

      private

      def authorized
        authorize(:payment, :create?)
      end
    end
  end
end
