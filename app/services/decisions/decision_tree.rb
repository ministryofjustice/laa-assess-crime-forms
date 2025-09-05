module Decisions
  class DecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    PAYMENT_START_PAGE = 'payments/steps/claim_type'.freeze
    PAYMENT_CHECK_ANSWERS = 'payments/steps/check_your_answers'.freeze

    CLAIM_TYPE = 'payments/steps/claim_type'.freeze
    CLAIM_DETAILS = 'payments/steps/claim_detail'.freeze
    ASSIGNED_COUNSEL_NSM = 'payments/steps/assigned_counsel_nsm'.freeze

    from(:claim_type)
      .when(-> { application.claim_type == Payments::ClaimType::NON_STANDARD_MAGISTRATE.to_s })
      .goto(edit: CLAIM_DETAILS)
      .when(-> { application.claim_type == Payments::ClaimType::ASSIGNED_COUNSEL.to_s })
      .goto(edit: ASSIGNED_COUNSEL_NSM)
  end
end
