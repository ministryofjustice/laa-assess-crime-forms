module Payments
  module Steps
    class BaseController < ::Steps::BaseStepController
      before_action :authorized

      layout 'payments'

      def decision_tree_class
        Decisions::DecisionTree
      end

      private

      def multi_step_form_session
        id = params[:id].presence || session[:multi_step_form_id]
        @multi_step_form_session ||= Decisions::MultiStepFormSession.new(process: 'payments',
                                                                         session: session,
                                                                         session_id: id)
      end

      def parent_claim_class
        @parent_claim_class ||= multi_step_form_session['request_type']
                                .sub(/_(supplemental|appeal|amendment)\z/, '').sub(/mag\z/, 'magistrate')
      end

      def authorized
        authorize(:payment, :update?)
      end
    end
  end
end
