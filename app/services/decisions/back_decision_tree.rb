module Decisions
  class BackDecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    # start_page - takes use back to previous page
    from(DecisionTree::CLAIM_DETAILS).goto(edit: DecisionTree::CLAIM_TYPE)
    from(DecisionTree::ASSIGNED_COUNSEL_NSM).goto(edit: DecisionTree::CLAIM_TYPE)
  end
end
