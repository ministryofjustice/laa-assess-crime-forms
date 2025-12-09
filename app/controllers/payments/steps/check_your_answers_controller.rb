module Payments
  module Steps
    class CheckYourAnswersController < BaseController
      include Payments::MultiStepFormSessionConcern

      before_action :set_form_session, only: [:edit], if: -> { params[:submission] }

      def edit
        @form_object = Payments::Steps::CheckYourAnswersForm.build(payment_details,
                                                                   multi_step_form_session:)
        @claim_details = details_class.new(payment_details)

        @cost_summary = cost_summary
      end

      private

      def details_class
        case multi_step_form_session['request_type'].to_sym
        when :non_standard_magistrate, :non_standard_mag_supplemental, :non_standard_mag_amendment, :non_standard_mag_appeal
          Payments::NsmClaimDetailsSummary
        when :assigned_counsel, :assigned_counsel_appeal, :assigned_counsel_amendment
          Payments::AcClaimDetailsSummary
        end
      end

      def payment_details
        @payment_details ||= if params[:submission]
                               payment_claim_details = BaseViewModel.build(:payment_claim_details, claim)
                               current_multi_step_form_session.answers = payment_claim_details.to_h
                             else
                               multi_step_form_session.answers
                             end
      end

      def claim
        @claim ||= Claim.load_from_app_store(params[:id])
      end

      def set_form_session
        multi_step_form_session && session[:multi_step_form_id] = params[:id]
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def cost_summary
        case multi_step_form_session['request_type'].to_sym
        when :non_standard_magistrate
          Payments::NsmCostsSummary.new(multi_step_form_session.answers, session[:multi_step_form_id])
        when :non_standard_mag_supplemental
          Payments::NsmCostsSummaryAmendedAndClaimed.new(multi_step_form_session.answers, session[:multi_step_form_id])
        when :non_standard_mag_amendment, :non_standard_mag_appeal
          Payments::NsmCostsSummaryAmended.new(multi_step_form_session.answers, session[:multi_step_form_id])
        when :assigned_counsel
          Payments::AcCostsSummary.new(multi_step_form_session.answers, session[:multi_step_form_id])
        when :assigned_counsel_appeal, :assigned_counsel_amendment
          if multi_step_form_session.answers['claimed_total'].present?
            Payments::AcCostsSummaryAmendedAndClaimed.new(multi_step_form_session.answers, session[:multi_step_form_id])
          else
            Payments::AcCostsSummaryAmended.new(multi_step_form_session.answers, session[:multi_step_form_id])
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
