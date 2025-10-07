module Payments
  class ClaimDetails
    include ActionView::Helpers::UrlHelper

    def initialize(payment_request_claim)
      @payment_request_claim = payment_request_claim
    end

    def id
      @payment_request_claim['id']
    end

    def claim_type
      I18n.t("shared.claim_type.#{@payment_request_claim['type']}")
    end

    def date_received
      DateTime.parse(@payment_request_claim['date_received']).to_fs(:stamp)
    end

    def office_code
      @payment_request_claim['office_code']
    end

    def firm_name
      @payment_request_claim['firm_name']
    end

    def ufn
      @payment_request_claim['ufn']
    end

    def stage_code
      @payment_request_claim['stage_code']
    end

    def defendant_first_name
      @payment_request_claim['client_first_name']
    end

    def defendant_last_name
      @payment_request_claim['client_last_name']
    end

    def defendant_name
      "#{defendant_first_name} #{defendant_last_name}"
    end

    def court_attendances
      @payment_request_claim['court_attendances']
    end

    def no_of_defendants
      @payment_request_claim['no_of_defendants']
    end

    def outcome_code
      LaaCrimeFormsCommon::OutcomeCode.new(@payment_request_claim['outcome_code']).name
    end

    def matter_type
      LaaCrimeFormsCommon::MatterType.new(@payment_request_claim['matter_type']).name
    end

    def court
      @payment_request_claim['court_name']
    end

    def youth_court
      @payment_request_claim['youth_court'] ? 'Yes' : 'No'
    end

    def laa_reference
      @payment_request_claim['laa_reference']
    end

    def last_updated
      DateTime.parse(@payment_request_claim['updated_at']).to_fs(:stamp)
    end

    def payment_requests
      @payment_requests ||= @payment_request_claim['payment_requests']
                            .map { Payments::PaymentRequestDetails.new(_1) }
                            .sort_by(&:date_completed).reverse
    end

    def current_total
      payment_requests.last.allowed_total
    end

    def work_completed_date
      DateTime.parse(@payment_request_claim['work_completed_date']).to_fs(:stamp)
    end

    def original_claim
      link_to("Link to: #{laa_reference}", '')
    end

    def table_format
      [
        [table_heading('original_claim'), { text: original_claim, numeric: false }],
        [table_heading('claim_type'), { text: claim_type, numeric: false }],
        [table_heading('date_received'), { text: date_received, numeric: false }],
        [table_heading('office_code'), { text: office_code, numeric: false }],
        [table_heading('firm_name'), { text: firm_name, numeric: false }],
        [table_heading('ufn'), { text: ufn, numeric: false }],
        [table_heading('stage_code'), { text: stage_code, numeric: false }],
        [table_heading('defendant_name'), { text: defendant_name, numeric: false }],
        [table_heading('no_of_defendants'), { text: no_of_defendants, numeric: false }],
        [table_heading('court_attendances'), { text: court_attendances, numeric: false }],
        [table_heading('outcome_code'), { text: outcome_code, numeric: false }],
        [table_heading('matter_type'), { text: matter_type, numeric: false }],
        [table_heading('court'), { text: court, numeric: false }],
        [table_heading('youth_court'), { text: youth_court, numeric: false }],
        [table_heading('work_completed_date'), { text: work_completed_date, numeric: false }],
      ]
    end

    def table_heading(key)
      I18n.t("payments.requests.claim_details.table.#{key}")
    end
  end
end
