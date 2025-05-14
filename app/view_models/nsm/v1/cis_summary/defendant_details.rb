module Nsm
  module V1
    module CisSummary
      class DefendantDetails < Nsm::V1::DefendantDetails
        def title
          I18n.t(".nsm.cis_summaries.#{key}.title")
        end

        def data
          [defendant_rows + defendant_count].flatten.compact
        end

        def main_defendant
          defendants.find { _1['main'] }
        end

        def main_defendant_rows
          [
            {
              title:  I18n.t(".nsm.cis_summaries.#{key}.defendant_last_name", position: '(lead)'),
              value: main_defendant['last_name']
            },
            {
              title:  I18n.t(".nsm.cis_summaries.#{key}.defendant_first_name", position: '(lead)'),
              value: main_defendant['first_name']
            }
          ]
        end

        def additional_defendant_rows
          additional_defendants.map.with_index do |defendant, index|
            [
              {
                title: I18n.t(".nsm.cis_summaries.#{key}.defendant_last_name", position: index + 2),
                value: defendant['last_name']
              },
              {
                title: I18n.t(".nsm.cis_summaries.#{key}.defendant_first_name", position: index + 2),
                value: defendant['first_name']
              }
            ]
          end
        end

        def defendant_count
          [
            {
              title: I18n.t(".nsm.cis_summaries.#{key}.number_of_defendants"),
              value: defendants.count
            }
          ]
        end
      end
    end
  end
end
