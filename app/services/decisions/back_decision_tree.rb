module Decisions
  class BackDecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    # start_page - takes use back to previous page
    from(DecisionTree::NSM_CLAIM_DETAILS).goto(edit: DecisionTree::CLAIM_TYPE)
    from(DecisionTree::AC_NSM_CHECK).goto(edit: DecisionTree::CLAIM_TYPE)
  end
end
