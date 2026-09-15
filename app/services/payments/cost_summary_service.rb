module Payments
  class CostSummaryService
    include PaymentsHelper

    def initialize(session_answers, to_be_paid, from_submission)
      @session_answers = session_answers
      @to_be_paid = to_be_paid
      @from_submission = from_submission
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def call
      if @session_answers['request_type'].start_with?('non_standard_mag_') && @to_be_paid
        Payments::NsmCostsSummaryToBePaid.new(@session_answers)
      elsif @session_answers['request_type'].start_with?('assigned_counsel') && @to_be_paid
        Payments::AcCostsSummaryToBePaid.new(@session_answers)
      else
        case @session_answers['request_type'].to_sym
        when :non_standard_magistrate, :breach_of_injunction
          Payments::NsmCostsSummary.new(@session_answers, from_submission: @from_submission)
        when :non_standard_mag_supplemental
          if @session_answers['laa_reference'].present? || @session_answers['linked_laa_reference'].present?
            Payments::NsmCostsSummaryAmendedAndClaimed.new(@session_answers)
          else
            Payments::NsmCostsSummary.new(@session_answers)
          end
        when :non_standard_mag_amendment, :non_standard_mag_appeal
          Payments::NsmCostsSummaryAmended.new(@session_answers)
        when :assigned_counsel
          Payments::AcCostsSummary.new(@session_answers)
        when :assigned_counsel_appeal
          Payments::AcCostsSummaryAppealed.new(@session_answers)
        when :assigned_counsel_amendment
          Payments::AcCostsSummaryAmended.new(@session_answers)
        # :nocov:
        else
          raise StandardError, "Unknown request type: #{@session_answers['request_type']}"
        end
        # :nocov:
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
