module Nsm
  module V1
    class PaymentClaimDetails < BaseViewModel
      attribute :matter_type
      attribute :youth_court
      attribute :court
      attribute :ufn

      attribute :submission
      delegate :id, to: :submission

      def linked_laa_reference
        submission.data[:laa_reference]
      end

      def date_completed
        submission.data[:work_completed_date]
      end

      def hearing_outcome_code
        submission.data[:hearing_outcome]
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

      def request_type
        submission.data[:claim_type]
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

      def date_received
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
          :court,
          :hearing_outcome_code,
          :stage_reached,
          :solicitor_firm_name,
          :solicitor_office_code,
          :date_completed,
          :matter_type,
          :ufn,
          :number_of_attendances,
          :number_of_defendants,
          :defendant_first_name,
          :defendant_last_name,
          :request_type,
          :date_received,
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
    end
  end
end
