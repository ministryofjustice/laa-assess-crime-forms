module Nsm
  module V1
    class PaymentClaimDetails < BaseViewModel
      attribute :matter_type
      attribute :youth_court
      attribute :ufn
      attrinbute :request_type

      attribute :submission
      delegate :id, to: :submission

      def original_submission_month
        original_submission_date.month
      end

      def original_submission_year
        original_submission_date.year
      end

      def linked_laa_reference
        submission.data[:laa_reference]
      end

      def date_completed
        submission.data[:work_completed_date]
      end

      def hearing_outcome_code
        submission.data[:hearing_outcome]
      end

      def court_id
        court_item&.id || I18n.t('laa_crime_forms_common.shared.custom')
      end

      def court_name
        court_item&.short_name || submission.data[:court].delete_suffix(' - n/a')
      end

      def stage_reached
        submission.data[:stage_reached].upcase
      end

      def solicitor_firm_name
        submission.data[:firm_office][:name]
      end

      def solicitor_office_code
        submission.data[:firm_office][:account_number]
      end

      def number_of_attendances
        submission.data[:number_of_hearing]
      end

      def defendant_first_name
        submission.data[:defendants].detect { _1[:main] == true }[:first_name]
      end

      def defendant_last_name
        submission.data[:defendants].detect { _1[:main] == true }[:last_name]
      end

      def number_of_defendants
        submission.data[:defendants].size
      end

      def claimed_profit_cost
        cost_summary[:profit_costs][:claimed_total_inc_vat]
      end

      def claimed_travel_cost
        cost_summary[:travel][:claimed_total_inc_vat]
      end

      def claimed_waiting_cost
        cost_summary[:waiting][:claimed_total_inc_vat]
      end

      def claimed_disbursement_cost
        cost_summary[:disbursements][:claimed_total_inc_vat]
      end

      def allowed_profit_cost
        cost_summary[:profit_costs][:assessed_total_inc_vat]
      end

      def allowed_travel_cost
        cost_summary[:travel][:assessed_total_inc_vat]
      end

      def allowed_waiting_cost
        cost_summary[:waiting][:assessed_total_inc_vat]
      end

      def allowed_disbursement_cost
        cost_summary[:disbursements][:assessed_total_inc_vat]
      end

      def allowed_total
        totals[:assessed_total_inc_vat]
      end

      def claimed_total
        totals[:claimed_total_inc_vat]
      end

      def date_claim_assessed
        Time.current.to_fs(:db)
      end

      def idempotency_token
        SecureRandom.uuid
      end

      # rubocop:disable Metrics/MethodLength
      def to_h
        [
          :id,
          :idempotency_token,
          :linked_laa_reference,
          :youth_court,
          :court_id,
          :court_name,
          :hearing_outcome_code,
          :stage_reached,
          :solicitor_firm_name,
          :solicitor_office_code,
          :original_submission_month,
          :original_submission_year,
          :date_completed,
          :matter_type,
          :ufn,
          :number_of_attendances,
          :number_of_defendants,
          :defendant_first_name,
          :defendant_last_name,
          :request_type,
          :date_claim_assessed,
          :claimed_profit_cost,
          :claimed_travel_cost,
          :claimed_waiting_cost,
          :claimed_disbursement_cost,
          :allowed_profit_cost,
          :allowed_travel_cost,
          :allowed_waiting_cost,
          :allowed_disbursement_cost,
          :allowed_total,
          :claimed_total
        ].index_with { |k| public_send(k) }.stringify_keys
      end
      # rubocop:enable Metrics/MethodLength

      private

      def totals
        submission.totals[:totals]
      end

      def cost_summary
        submission.totals[:cost_summary]
      end

      def court_item
        LaaCrimeFormsCommon::Court.all.find { |c| submission.data[:court].downcase == c.name.downcase }
      end

      def original_submission_date
        if request_type.in?(
          %w[
            non_standard_mag_appeal
            non_standard_mag_amendment
            non_standard_mag_supplemental
          ]
        )
          decision_date
        else
          Date.current
        end
      end

      def decision_date
        grant_event = submission.events.detect { |e| e.event_type == 'Event::Decision' }

        raise "No decision event found for submission: #{submission.id}" if grant_event.blank?

        grant_event.created_at
      end
    end
  end
end
