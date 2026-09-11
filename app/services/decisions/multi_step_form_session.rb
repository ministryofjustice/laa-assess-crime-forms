module Decisions
  class MultiStepFormSession
    attr_reader :session, :id, :process

    def initialize(process:, session:, session_id:)
      @process = process
      @session = session
      @id = session_id
      create!
    end

    def answers
      data['answers']
    end

    def answers=(claim_hash)
      data['answers'] = claim_hash
    end

    def reset_answers
      data['answers'] = { 'id' => id, 'idempotency_token' => SecureRandom.uuid }
    end

    def [](hash_key)
      answers[hash_key.to_s]
    end

    def []=(hash_key, hash_value)
      answers[hash_key.to_s] = if hash_value.class.in? [TrueClass, FalseClass]
                                 hash_value
                               else
                                 hash_value.to_s
                               end
    end

    def no_existing_ref?
      answers['laa_reference'].blank? && answers['linked_nsm_reference'].blank? && answers['linked_laa_reference'].blank?
    end

    def payment_basis
      if answers['request_type'].in? %w[non_standard_magistrate assigned_counsel]
        LaaCrimeFormsCommon::PaymentBasis::NEW_UNLINKED_RECORD
      elsif (linked_payment? && no_original_payment?) || no_existing_ref?
        LaaCrimeFormsCommon::PaymentBasis::LINKED_NO_ORIGINAL_PAYMENT
      elsif linked_payment?
        LaaCrimeFormsCommon::PaymentBasis::EXISTING_PAYMENT_RECORD
      else
        raise 'Unknown payment basis'
      end
    end

    def calculation_method
      LaaCrimeFormsCommon::PaymentBasis.calculation_method_for(payment_basis)
    end

    def to_be_paid?
      # original payments have an entered to be paid calculation method for totals
      # but we need to capture claimed and allowed values as normal
      return false if answers['request_type'].in? %w[non_standard_magistrate assigned_counsel]

      calculation_method == LaaCrimeFormsCommon::PaymentBasis::ENTERED_TO_BE_PAID
    end

    private

    def no_original_payment?
      request_type = if answers['request_type'].start_with?('non_standard_mag')
                       'non_standard_magistrate'
                     elsif answers['request_type'].start_with?('assigned_counsel')
                       'assigned_counsel'
                     else
                       raise 'Unknown request type'
                     end
      search_params = {
        query: answers['laa_reference'] || answers['linked_laa_reference'],
        request_type: request_type
      }
      results = AppStoreClient.new.search(search_params, :payment_requests)

      results.dig('metadata', 'total_results').zero?
    end

    def linked_payment?
      answers['request_type'].in?(
        %w[
          non_standard_mag_supplemental
          non_standard_mag_amendment
          non_standard_mag_appeal
          assigned_counsel_appeal
          assigned_counsel_amendment
        ]
      )
    end

    def create!
      # rubocop:disable Rails/Presence
      if session[key].blank?
        session[key] = {
          'answers' => { 'id' => id,
            'idempotency_token' => SecureRandom.uuid }
        }
      else
        session[key]
      end
      # rubocop:enable Rails/Presence
    end

    def key
      "#{process}:#{id}"
    end

    def data
      session[key]
    end
  end
end
