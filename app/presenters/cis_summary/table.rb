module CisSummary
  class Table
    KEYS = %i[
      CisSummary::ContactDetails
      CisSummary::DefendantDetails
      CisSummary::DetailsOfClaim
      CisSummary::HearingDetails
    ].freeze

    attr_reader :claim

    def initialize(claim)
      @claim = claim
    end

    def table
      KEYS.map do |key|
        BaseViewModel.build(key, claim).rows
      end
    end
  end
end
