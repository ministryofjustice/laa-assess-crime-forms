module PaymentsHelper
  def month_name(date)
    "#{date.strftime('%B')} #{date.year}"
  end

  def no_existing_ref?(payment_hash)
    payment_hash['laa_reference'].blank? &&
      payment_hash['linked_nsm_reference'].blank? &&
      payment_hash['linked_laa_reference'].blank?
  end

  def payment_basis(payment_hash)
    linked_payment = linked_payment?(payment_hash['request_type'])
    if payment_hash['request_type'].in? %w[non_standard_magistrate assigned_counsel]
      LaaCrimeFormsCommon::PaymentBasis::NEW_UNLINKED_RECORD
    elsif (linked_payment && no_original_payment?(payment_hash)) || no_existing_ref?(payment_hash)
      LaaCrimeFormsCommon::PaymentBasis::LINKED_NO_ORIGINAL_PAYMENT
    elsif linked_payment
      LaaCrimeFormsCommon::PaymentBasis::EXISTING_PAYMENT_RECORD
    # :nocov:
    else
      raise 'Unknown payment basis'
    end
    # :nocov:
  end

  def to_be_paid?(payment_hash)
    # original payments have an entered to be paid calculation method for totals
    # but we need to capture claimed and allowed values as normal
    return false if payment_hash['request_type'].in? %w[non_standard_magistrate assigned_counsel]

    LaaCrimeFormsCommon::PaymentBasis.calculation_method_for(payment_basis(payment_hash)) == LaaCrimeFormsCommon::PaymentBasis::ENTERED_TO_BE_PAID
  end

  def linked_payment?(request_type)
    request_type.in?(
      %w[
        non_standard_mag_supplemental
        non_standard_mag_amendment
        non_standard_mag_appeal
        assigned_counsel_appeal
        assigned_counsel_amendment
      ],
    )
  end

  private

  def no_original_payment?(payment_hash)
    original_payment_type = LaaCrimeFormsCommon::PaymentFamily.get_claim_type_marker(payment_hash['request_type'])
    search_params = {
      query: payment_hash['laa_reference'] || payment_hash['linked_laa_reference'],
      request_type: original_payment_type
    }
    results = AppStoreClient.new.search(search_params, :payment_requests)

    results.dig('metadata', 'total_results').zero?
  end
end
