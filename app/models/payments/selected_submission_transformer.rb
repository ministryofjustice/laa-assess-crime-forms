module Payments
  class SelectedSubmissionTransformer < BaseSelectedTransformer
    def transform
      load_claim = claim
      latest_payment_request = dup_original_costs_to(claim)
      claim = format_claim(load_claim)
      claim.merge!(latest_payment_request)
    end

    private

    def claim
      loaded_claim = Claim.load_from_app_store(payment_request_claim_id)
      @claim ||= BaseViewModel.build(:payment_claim_details, loaded_claim).to_h.with_indifferent_access
    end

    def format_claim(claim)
      claim = format_ac_claim(claim) if multi_step_form_session['request_type'].in?(%w[assigned_counsel assigned_counsel_appeal
                                                                                       assigned_counsel_amendment])
      claim[:id] = claim[:submission_id]
      # claim[:laa_reference] = claim[:linked_laa_reference]
      claim.except!(*response_except_list)
    end

    def dup_original_costs_to(hash)
      hash.with_indifferent_access.keys.each do |key|
        next unless claim_amount_keys.include?(key.to_sym)

        hash[:"original_#{key}"] = hash[key]
      end
      hash
    end

    def response_except_list
      [:payment_requests,
       :created_at,
       :updated_at,
       :type,
       :nsm_claim,
       :assigned_counsel_claim,
       :request_type,
       :idempotency_token,
       :date_received,
       :submission_id]
    end

    def claim_amount_keys
      [
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
      ]
    end
  end
end
