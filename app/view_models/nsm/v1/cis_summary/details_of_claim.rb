module Nsm
  module V1
    module CisSummary
      class DetailsOfClaim < Nsm::V1::DetailsOfClaim
        def title
          I18n.t(".nsm.cis_summaries.#{key}.title")
        end

        def data
          [
            {
              title: I18n.t(".nsm.cis_summaries.#{key}.ufn"),
              value: ufn
            },
            {
              title: I18n.t(".nsm.cis_summaries.#{key}.stage_reached"),
              value: I18n.t(".nsm.cis_summaries.#{key}.stages.#{stage_reached}")
            },
          ]
        end
      end
    end
  end
end
