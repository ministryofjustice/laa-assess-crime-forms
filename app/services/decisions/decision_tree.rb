module Decisions
  class DecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    PAYMENT_START_PAGE = 'steps/claim_type'.freeze

    CLAIM_TYPE = '/payments/steps/claim_types'.freeze

    NSM_CLAIM_DETAILS = 'payments/steps/nsm/claim_details'.freeze
    NSM_CLAIMED_COSTS = 'payments/steps/nsm/claimed_costs'.freeze
    NSM_ALLOWED_COSTS = 'payments/steps/nsm/allowed_costs'.freeze

    DATE_RECEIVED = '/payments/steps/date_received'.freeze
    CLAIM_SEARCH = '/payments/steps/claim_search'.freeze
    CHECK_YOUR_ANSWERS = '/payments/steps/check_your_answers'.freeze

    SUBMIT = 'payments'.freeze

    from(:claim_type)
      .when(-> { nsm })
      .goto(edit: NSM_CLAIM_DETAILS)
      .when(-> { nsm_supplemental || nsm_appeal || nsm_amendment })
      .goto(edit: CLAIM_SEARCH)

    from(:claim_search)
      .goto(edit: DATE_RECEIVED)

    from(:date_received)
      .when(-> { nsm_supplemental })
      .goto(edit: NSM_CLAIMED_COSTS)
      .when(-> { nsm_appeal || nsm_amendment })
      .goto(edit: NSM_ALLOWED_COSTS)

    from(:nsm_claim_details)
      .when(-> { nsm_appeal || nsm_amendment })
      .goto(edit: NSM_ALLOWED_COSTS)
      .when(-> { nsm || nsm_supplemental })
      .goto(edit: NSM_CLAIMED_COSTS)
    from(:nsm_claimed_costs)
      .goto(edit: NSM_ALLOWED_COSTS)
    from(:nsm_allowed_costs)
      .goto(edit: CHECK_YOUR_ANSWERS)

    from(:check_your_answers)
      .goto(show: SUBMIT)
  end
end
