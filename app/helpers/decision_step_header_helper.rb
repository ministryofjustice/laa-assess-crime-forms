module DecisionStepHeaderHelper
  def previous_decision_step_path
    form_session = Decisions::MultiStepFormSession.new(process: 'payments',
                                                       session: session, session_id: session[:multi_step_form_id])
    form = Payments::Steps::BasePaymentsForm.new(multi_step_form_session: form_session,
                                                 form_data: form_session.answers)
    Decisions::BackDecisionTree.new(
      form,
      as: request.path_parameters[:controller]
    ).destination
  end
end
