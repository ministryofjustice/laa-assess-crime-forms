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

      def decision_context
        return {} unless return_to_cya_requested?

        { return_to_cya: true }
      end

      # :nocov:
      def decorate_decision_destination(destination)
        return destination unless return_to_cya_requested?
        return destination unless destination[:action] == :edit
        return destination if destination[:controller] == Decisions::DecisionTree::CHECK_YOUR_ANSWERS

        destination.merge(return_to_cya: 1)
      end
      # :nocov:

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

      def return_to_cya_requested?
        return true if params[:return_to_cya].present?

        params.to_unsafe_h.values.any? do |value|
          value.is_a?(Hash) && value['return_to_cya'].present?
        end
      end
    end
  end
end
