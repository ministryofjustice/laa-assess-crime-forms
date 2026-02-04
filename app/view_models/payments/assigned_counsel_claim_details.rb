module Payments
  class AssignedCounselClaimDetails < BaseClaimDetails
    include ActionView::Helpers::UrlHelper

    def firm_name
      @payment_request_claim['counsel_firm_name']
    end

    def defendant_last_name
      @payment_request_claim['defendant_last_name']
    end

    def linked_claim
      @payment_request_claim.dig('nsm_claim', 'laa_reference') || I18n.t('payments.requests.claim_details.table.no_linked_claim')
    end

    def solicitor_office_code
      @payment_request_claim.dig('nsm_claim', 'solicitor_office_code') || @payment_request_claim['solicitor_office_code']
    end

    def solicitor_firm_name
      @payment_request_claim.dig('nsm_claim', 'solicitor_firm_name') || @payment_request_claim['solicitor_firm_name']
    end

    def ufn
      @payment_request_claim['ufn']
    end

    def counsel_office_code
      @payment_request_claim['counsel_office_code']
    end

    def table_format
      [
        [table_heading('claim_type'), { text: claim_type, numeric: false }],
        [table_heading('linked_claim'), { text: linked_claim, numeric: false }],
        [table_heading('solicitor_office_code'), { text: solicitor_office_code, numeric: false }],
        [table_heading('solicitor_firm_name'), { text: solicitor_firm_name, numeric: false }],
        [table_heading('ufn'), { text: ufn, numeric: false }],
        [table_heading('defendant_last_name'), { text: defendant_last_name, numeric: false }],
        [table_heading('counsel_office_code'), { text: counsel_office_code, numeric: false }],
        [table_heading('counsel_firm_name'), { text: firm_name, numeric: false }]
      ]
    end
  end
end
