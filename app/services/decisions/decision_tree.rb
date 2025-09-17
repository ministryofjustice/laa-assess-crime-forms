module Decisions
  class DecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    PAYMENT_START_PAGE = 'steps/claim_type'.freeze
    PAYMENT_CHECK_ANSWERS = 'steps/check_your_answers'.freeze

    CLAIM_TYPE = '/payments/steps/claim_types'.freeze

    AC_CLAIM_DETAILS = 'payments/steps/ac/claim_details'.freeze
    AC_CLAIMED_COSTS = 'payments/steps/ac/claimed_costs'.freeze
    AC_ALLOWED_COSTS = 'payments/steps/ac/allowed_costs'.freeze
    AC_NSM_CHECK = 'payments/steps/ac/nsm_check'.freeze

    NSM_LAA_REFERENCE_CHECK = 'payments/steps/nsm/laa_reference_check'.freeze
    NSM_CLAIM_DETAILS = 'payments/steps/nsm/claim_details'.freeze
    NSM_CLAIMED_COSTS = 'payments/steps/nsm/claimed_costs'.freeze
    NSM_ALLOWED_COSTS = 'payments/steps/nsm/allowed_costs'.freeze

    DATE_RECEIVED = '/payments/steps/date_received'.freeze
    LAA_REFERENCE = '/payments/steps/laa_reference'.freeze
    CHECK_YOUR_ANSWERS = '/payments/steps/check_your_answers'.freeze

    SUBMIT = 'payments'.freeze

    from(:claim_type)
      .when(-> { nsm })
      .goto(edit: NSM_CLAIM_DETAILS)
      .when(-> { nsm_supplemental || nsm_appeal || nsm_amendment })
      .goto(edit: NSM_LAA_REFERENCE_CHECK)
      .when(-> { ac })
      .goto(edit: AC_NSM_CHECK)
      .when(-> { ac_appeal || ac_amendment })
      .goto(edit: LAA_REFERENCE)

    from(:laa_reference_check)
      .when(-> { multi_step_form_session['laa_reference_check'] == true })
      .goto(edit: LAA_REFERENCE)
      .when(-> { multi_step_form_session['laa_reference_check'] == false })
      .goto(edit: NSM_CLAIM_DETAILS)
    from(:laa_reference)
      .when(-> { nsm_supplemental || nsm_appeal || nsm_amendment || ac_appeal || ac_amendment })
      .goto(edit: DATE_RECEIVED)
      .when(-> { ac })
      .goto(edit: AC_CLAIM_DETAILS)

    from(:date_received)
      .when(-> { nsm_supplemental })
      .goto(edit: NSM_CLAIMED_COSTS)
      .when(-> { nsm_appeal || nsm_amendment })
      .goto(edit: NSM_ALLOWED_COSTS)

    from(:ac_claim_details)
      .goto(edit: AC_CLAIMED_COSTS)
    from(:ac_claimed_costs)
      .goto(edit: AC_ALLOWED_COSTS)
    from(:ac_allowed_costs)
      .goto(show: CHECK_YOUR_ANSWERS)

    from(:nsm_claim_details)
      .when(-> { nsm_appeal || nsm_amendment })
      .goto(edit: NSM_ALLOWED_COSTS)
      .when(-> { nsm || nsm_supplemental })
      .goto(edit: NSM_CLAIMED_COSTS)
    from(:nsm_claimed_costs)
      .goto(edit: NSM_ALLOWED_COSTS)
    from(:nsm_allowed_costs)
      .goto(show: CHECK_YOUR_ANSWERS)

    from(:check_your_answers)
      .goto(show: SUBMIT)
  end
end
