module Payments
  class NsmClaimDetails < BaseClaimDetails
    include ActionView::Helpers::UrlHelper

    def solicitor_office_code
      @payment_request_claim['solicitor_office_code']
    end

    def firm_name
      @payment_request_claim['solicitor_firm_name']
    end

    def ufn
      @payment_request_claim['ufn']
    end

    def stage_code
      @payment_request_claim['stage_reached']
    end

    def defendant_first_name
      @payment_request_claim['defendant_first_name']
    end

    def defendant_last_name
      @payment_request_claim['defendant_last_name']
    end

    def defendant_name
      "#{defendant_first_name} #{defendant_last_name}"
    end

    def court_attendances
      @payment_request_claim['number_of_attendances']
    end

    def no_of_defendants
      @payment_request_claim['number_of_defendants']
    end

    def outcome_code
      LaaCrimeFormsCommon::OutcomeCode.new(@payment_request_claim['hearing_outcome_code']).name
    end

    def matter_type
      LaaCrimeFormsCommon::MatterType.new(@payment_request_claim['matter_type']).name
    end

    def court
      @payment_request_claim['court']
    end

    def youth_court
      @payment_request_claim['youth_court'] ? 'Yes' : 'No'
    end

    def work_completed_date
      DateTime.parse(@payment_request_claim['work_completed_date']).to_fs(:stamp)
    end

    def original_claim
      return unless submission

      link_to(
        "Link to: #{laa_reference}",
        "/nsm/claims/#{submission_id}/claim_details"
      )
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def table_format
      [
        original_claim_row,
        [table_heading('claim_type'), { text: claim_type, numeric: false }],
        [table_heading('office_code'), { text: solicitor_office_code, numeric: false }],
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
      ].compact
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    # TODO: CRM457-2686 may affect this
    def submission
      @submission ||= submission_id ? AppStoreClient.new.get_submission(submission_id) : nil
    end

    def submission_id
      @payment_request_claim['submission_id']
    end

    def original_claim_row
      original_claim ? [table_heading('original_claim'), { text: original_claim, numeric: false }] : nil
    end
  end
end
