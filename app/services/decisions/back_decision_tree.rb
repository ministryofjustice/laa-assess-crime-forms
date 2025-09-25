module Decisions
  class BackDecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper
    CHECK_YOUR_ANSWERS = 'payments/steps/check_your_answers'.freeze

    from(DecisionTree::NSM_CLAIM_DETAILS)
      .when(-> { nsm })
      .goto(edit: DecisionTree::CLAIM_TYPE)
      .when(-> { nsm_supplemental || nsm_appeal || nsm_amendment })
      .goto(edit: DecisionTree::NSM_LAA_REFERENCE_CHECK)
    from(DecisionTree::LAA_REFERENCE.sub(%r{^/}, ''))
      .goto(edit: DecisionTree::NSM_LAA_REFERENCE_CHECK)
    from(DecisionTree::DATE_RECEIVED.sub(%r{^/}, ''))
      .goto(edit: DecisionTree::LAA_REFERENCE)
    from(DecisionTree::NSM_LAA_REFERENCE_CHECK).goto(edit: DecisionTree::CLAIM_TYPE)
    from(DecisionTree::NSM_CLAIMED_COSTS)
      .when(-> { nsm })
      .goto(edit: DecisionTree::NSM_CLAIM_DETAILS)
      .when(-> { nsm_supplemental })
      .goto(edit: DecisionTree::DATE_RECEIVED)
    from(DecisionTree::NSM_ALLOWED_COSTS)
      .when(-> { nsm || nsm_supplemental })
      .goto(edit: DecisionTree::NSM_CLAIMED_COSTS)
      .when(-> { (nsm_appeal || nsm_amendment) && laa_reference_check })
      .goto(edit: DecisionTree::DATE_RECEIVED)
      .when(-> { (nsm_appeal || nsm_amendment) && !laa_reference_check })
      .goto(edit: DecisionTree::NSM_CLAIM_DETAILS)
    from(CHECK_YOUR_ANSWERS).goto(edit: DecisionTree::NSM_ALLOWED_COSTS)
  end
end
