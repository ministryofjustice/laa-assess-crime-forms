module Payments
  class AssignedCounselClaimDetails < BaseClaimDetails
    include ActionView::Helpers::UrlHelper

    def firm_name
      @payment_request_claim['counsel_firm_name']
    end

    def client_last_name
      @payment_request_claim['client_last_name']
    end

    def linked_claim
      @payment_request_claim['nsm_claim']['laa_reference']
    end

    def date_received
      @payment_request_claim['date_received']
    end

    def solicitor_office_code
      @payment_request_claim['nsm_claim']['office_code']
    end

    def solicitor_firm_name
      @payment_request_claim['nsm_claim']['firm_name']
    end

    def ufn
      @payment_request_claim['nsm_claim']['ufn']
    end

    def counsel_office_code
      @payment_request_claim['counsel_office_code']
    end

    def table_format
      [
        [table_heading('claim_type'), { text: claim_type, numeric: false }],
        [table_heading('linked_claim'), { text: linked_claim, numeric: false }],
        [table_heading('date_received'), { text: date_received, numeric: false }],
        [table_heading('solicitor_office_code'), { text: solicitor_office_code, numeric: false }],
        [table_heading('solicitor_firm_name'), { text: solicitor_firm_name, numeric: false }],
        [table_heading('ufn'), { text: ufn, numeric: false }],
        [table_heading('client_last_name'), { text: client_last_name, numeric: false }],
        [table_heading('counsel_office_code'), { text: counsel_office_code, numeric: false }],
        [table_heading('counsel_firm_name'), { text: firm_name, numeric: false }]
      ].compact
    end
  end
end
