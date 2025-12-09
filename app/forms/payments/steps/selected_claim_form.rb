module Payments
  module Steps
    class SelectedClaimForm < BasePaymentsForm
      attribute :payment_request_claim_id

      validates :payment_request_claim_id, presence: true

      def save
        return false unless valid?

        raise StandardError unless claim

        claim.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      end

      def claim
        claim = payment_request_claim.deep_stringify_keys.with_indifferent_access
        latest_payment_request = latest_payment_request(claim)
        claim.except!(:payment_requests, :created_at, :updated_at, :type, :id)
        claim.except!(:ufn) if multi_step_form_session['request_type'] == 'assigned_counsel'
        claim.merge!(latest_payment_request)
      end

      def latest_payment_request(claim)
        payment_requests = claim.with_indifferent_access[:payment_requests]
        return nil if payment_requests.blank?

        payment_requests = payment_requests.map(&:with_indifferent_access)

        payment_request = payment_requests.max_by do |pr|
          DateTime.parse(pr[:updated_at].to_s)
        end.except!(:id, :created_at, :updated_at,
                    :date_received, :request_type,
                    :submitter_id, :submitted_at)

        dup_original_costs_to(payment_request)
      end

      def payment_request_claim
        @payment_request_claim ||= AppStoreClient.new.get_payment_request_claim(payment_request_claim_id)
      end

      def dup_original_costs_to(hash)
        key_syms = claim_amount_keys[payment_request_claim['type'].underscore.to_sym]
        hash.keys.each do |key|
          next unless key_syms.include?(key.to_sym)

          hash[:"original_#{key}"] = hash[key]
        end
        hash
      end

      # rubocop:disable Metrics/MethodLength
      def claim_amount_keys
        {
          nsm_claim: [
            :claimed_profit_cost,
            :allowed_profit_cost,
            :claimed_travel_cost,
            :allowed_travel_cost,
            :claimed_waiting_cost,
            :allowed_waiting_cost,
            :claimed_disbursement_cost,
            :allowed_disbursement_cost,
            :claimed_total,
            :allowed_total
          ],
          assigned_counsel_claim: [
            :claimed_net_assigned_counsel_cost,
            :claimed_assigned_counsel_vat,
            :allowed_net_assigned_counsel_cost,
            :allowed_assigned_counsel_vat,
            :claimed_total,
            :allowed_total
          ]
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
