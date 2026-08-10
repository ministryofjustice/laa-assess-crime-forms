module DecisionStepHeaderHelper
  def previous_decision_step_path
    form_session = Decisions::MultiStepFormSession.new(process: 'payments',
                                                       session: session, session_id: session[:multi_step_form_id])
    form = Payments::Steps::BasePaymentsForm.new(multi_step_form_session: form_session,
                                                 form_data: form_session.answers)
    Decisions::BackDecisionTree.new(form, as:).destination
  end

  private

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def as
    current_request = request.path_parameters[:controller].split('/').last
    current_path = request.path
    referer_path = request.referer.present? ? URI.parse(request.referer).path : nil

    # If browser reload, default to current controller
    return request.path_parameters[:controller] if referer_path.present? && referer_path == current_path

    # If on form navigated from CYA page, return CYA controller to allow back link to return to CYA page
    current_referer = referer_path&.split('/')&.last
    back_to_cya = %w[claim_search claimed_costs allowed_costs submission_allowed_costs office_code_search]

    if back_to_cya.include?(current_request) && current_referer == 'check_your_answers'
      'change_your_answers'
    else
      request.path_parameters[:controller]
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
