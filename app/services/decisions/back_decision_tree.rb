module Decisions
  class BackDecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper
    CHECK_YOUR_ANSWERS = 'payments/steps/check_your_answers'.freeze

    from(DecisionTree::NSM_CLAIM_DETAILS)
      .goto(edit: DecisionTree::CLAIM_TYPE)
    from(DecisionTree::DATE_RECEIVED.sub(%r{^/}, ''))
      .goto(edit: DecisionTree::CLAIM_SEARCH.sub(%r{^/}, ''))
    from(DecisionTree::CLAIM_SEARCH.sub(%r{^/}, ''))
      .goto(edit: DecisionTree::CLAIM_TYPE)
    from(DecisionTree::NSM_CLAIMED_COSTS)
      .when(-> { nsm })
      .goto(edit: DecisionTree::NSM_CLAIM_DETAILS)
      .when(-> { nsm_supplemental })
      .goto(edit: DecisionTree::DATE_RECEIVED)
    from(DecisionTree::NSM_ALLOWED_COSTS)
      .when(-> { nsm })
      .goto(edit: DecisionTree::NSM_CLAIMED_COSTS)
      .when(-> { nsm_supplemental })
      .goto(edit: DecisionTree::NSM_CLAIMED_COSTS)
      .when(-> { nsm_appeal || nsm_amendment })
      .goto(edit: DecisionTree::DATE_RECEIVED)
    from(DecisionTree::SUBMISSION_ALLOWED_COSTS)
      .goto(edit: CHECK_YOUR_ANSWERS)
    from(CHECK_YOUR_ANSWERS)
      .goto(edit: DecisionTree::NSM_ALLOWED_COSTS)

    from(DecisionTree::LINKED_CLAIM_SEARCH.sub(%r{^/}, ''))
      .goto(edit: DecisionTree::CLAIM_TYPE)
    from(DecisionTree::AC_CLAIM_DETAILS)
      .goto(edit: DecisionTree::LINKED_CLAIM_SEARCH.sub(%r{^/}, ''))
  end
end
