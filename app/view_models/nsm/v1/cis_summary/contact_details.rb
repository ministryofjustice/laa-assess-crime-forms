module Nsm
  module V1
    module CisSummary
      class ContactDetails < Nsm::V1::ContactDetails
        def title
          I18n.t(".nsm.cis_summaries.#{key}.title")
        end

        def firm_account
          firm_office['account_number']
        end

        def data
          [
            {
              title: I18n.t(".nsm.cis_summaries.#{key}.firm_account"),
              value: firm_account
            },
            {
              title: I18n.t(".nsm.cis_summaries.#{key}.firm_name"),
              value: firm_name
            },
          ]
        end
      end
    end
  end
end
