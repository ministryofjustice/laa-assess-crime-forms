module Payments
  module Steps
    class CheckYourAnswersController < BaseController
      def edit
        @form_object = Payments::Steps::CheckYourAnswersForm.build(multi_step_form_session.answers,
                                                                   multi_step_form_session:)
        @claim_details = Payments::ClaimDetailsSummary.new(multi_step_form_session.answers)
        @cost_summary = cost_summary
      end

      private

      def cost_summary
        case multi_step_form_session['request_type'].to_sym
        when :non_standard_mag
          Payments::CostsSummary.new(multi_step_form_session.answers)
        when :non_standard_mag_supplemental
          Payments::CostsSummaryAmendedAndClaimed.new(multi_step_form_session.answers)
        when :non_standard_mag_amendment, :non_standard_mag_appeal
          Payments::CostsSummaryAmended.new(multi_step_form_session.answers)
        end
      end
    end
  end
end
