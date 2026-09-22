module Payments
  module Steps
    class BaseController < ::Steps::BaseStepController
      before_action :authorized
      before_action :redirect_old_session, only: [:edit]

      layout 'payments'

      def decision_tree_class
        Decisions::DecisionTree
      end

      # :nocov:
      def edit
        raise 'implement this action, if needed, in subclasses'
      end
      # :nocov:

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

      def redirect_old_session
        # Redirect to Request a Payment home page if trying to access a
        # payment request construction form without an existing session object
        # avoids redirecting when session object isn't present when:
        # 1. Accessing the first step (choosing payment request type)
        # 2. Accessing the Check Your Answers step from granted/part granted claim

        return if instance_of?(Payments::Steps::ClaimTypesController) || multi_step_form_session.answers['request_type'].present?
        return if instance_of?(Payments::Steps::CheckYourAnswersController) && params[:submission].present?

        redirect_to payments_requests_path
      end
    end
  end
end
