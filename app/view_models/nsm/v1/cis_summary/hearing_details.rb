module Nsm
  module V1
    module CisSummary
      class HearingDetails < Nsm::V1::HearingDetails
        attribute :work_completed_date

        def title
          I18n.t(".nsm.cis_summaries.#{key}.title")
        end

        def data
          [
            hearing_outcome_field,
            matter_type_field,
            work_completed_field,
            number_of_hearing_field,
            court_field,
            youth_court_field
          ]
        end

        private

        def hearing_outcome_field
          {
            title: I18n.t(".nsm.cis_summaries.#{key}.hearing_outcome"),
            value: "#{hearing_outcome.value} - #{hearing_outcome}"
          }
        end

        def matter_type_field
          {
            title: I18n.t(".nsm.cis_summaries.#{key}.matter_type"),
            value: "#{matter_type.value} - #{matter_type}"
          }
        end

        def work_completed_field
          {
            title: I18n.t(".nsm.cis_summaries.#{key}.work_completed_date"),
            value: format_in_zone(work_completed_date)
          }
        end

        def number_of_hearing_field
          {
            title: I18n.t('.nsm.cis_summaries.hearing_details.number_of_hearing'),
            value: number_of_hearing
          }
        end

        def court_field
          {
            title: I18n.t(".nsm.cis_summaries.#{key}.court"),
            value: court
          }
        end

        def youth_court_field
          {
            title: I18n.t(".nsm.cis_summaries.#{key}.youth_court"),
            value: youth_court.capitalize
          }
        end
      end
    end
  end
end
