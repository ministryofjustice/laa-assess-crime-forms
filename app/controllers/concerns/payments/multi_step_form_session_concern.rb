module Payments
  module MultiStepFormSessionConcern
    extend ActiveSupport::Concern

    def destroy_current_form_session
      ['multi_step_form_id', "payments:#{session[:multi_step_form_id]}"].each { session.delete(_1) }
    end

    def create_new_form_session
      session[:multi_step_form_id] = SecureRandom.uuid
      Decisions::MultiStepFormSession.new(process: 'payments',
                                          session: session,
                                          session_id: session[:multi_step_form_id])
    end

    def current_multi_step_form_session
      @current_multi_step_form_session ||= Decisions::MultiStepFormSession.new(
        process: 'payments',
        session: session,
        session_id: session[:multi_step_form_id]
      )
    end

    def cycle_multi_step_form_session_object
      if session[:multi_step_form_id].present?
        destroy_current_form_session && create_new_form_session
      else
        create_new_form_session
      end
    end
  end
end
