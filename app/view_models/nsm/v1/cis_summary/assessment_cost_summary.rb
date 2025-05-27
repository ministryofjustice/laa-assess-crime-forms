module Nsm
  module V1
    module CisSummary
      class AssessmentCostSummary < Nsm::V1::CoreCostSummary
        def headers
          [
            blank_header,
            t('request_gross'),
            t('allowed_gross')
          ]
        end

        private

        def blank_header
          {
            text: '',
            numeric: false,
            width: 'govuk-!-width-one-quarter'
          }
        end

        def build_row(type)
          data = submission.totals[:cost_summary][type]

          {
            name: t(type, numeric: false),
            gross_cost: format(data[:claimed_total_inc_vat]),
            allowed_gross_cost: format_allowed(data[:assessed_total_inc_vat]),
          }
        end
      end
    end
  end
end
