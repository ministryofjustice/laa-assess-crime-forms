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

      # :nocov:
      def parent_claim_class
        parent_scope = multi_step_form_session['request_type']
                       .sub(/_(supplemental|appeal|amendment)\z/, '').sub(/mag\z/, 'magistrate')

        @parent_claim_class ||= case parent_scope.to_sym
                                when :non_standard_magistrate, :breach_of_injunction
                                  :non_standard_magistrate
                                when :assigned_counsel
                                  :assigned_counsel
                                end
      end

      # :nocov:
      def authorized
        authorize(:payment, :update?)
      end
    end
  end
end
