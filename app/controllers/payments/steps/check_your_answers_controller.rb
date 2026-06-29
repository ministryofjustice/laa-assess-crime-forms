module Payments
  module Steps
    class CheckYourAnswersController < BaseController
      include Payments::MultiStepFormSessionConcern

      before_action :clear_stale_submission_session, only: [:edit], if: -> { params[:submission] }
      before_action :set_form_session, only: [:edit], if: -> { params[:submission] }

      def edit
        @form_object = Payments::Steps::CheckYourAnswersForm.build(payment_details,
                                                                   multi_step_form_session:)
        redirect_to your_nsm_claims_path and return if multi_step_form_session['request_type'].blank?

        @report = Payments::CheckYourAnswers::Report.new(payment_details, params)
      end

      private

      def payment_details
        @payment_details ||= begin
          if submission?
            answers = refresh_answers_from_claim
            answers['submission'] = true
            apply_persisted_submission_token!(answers)
            current_multi_step_form_session.answers = answers
          end

          current_multi_step_form_session.answers
        end
      end

      def submission?
        ActiveModel::Type::Boolean.new.cast(params[:submission])
      end

      def refresh_answers_from_claim
        payment_claim_details = BaseViewModel.build(:payment_claim_details, claim)
        payment_claim_details.request_type = 'non_standard_magistrate'
        payment_claim_details.to_h.with_indifferent_access
      end

      def apply_persisted_submission_token!(answers)
        previous_token = persisted_submission_token
        answers['idempotency_token'] = previous_token if previous_token.present?
      end

      def persisted_submission_token
        previous_submission = session[:payments_last_submission]
        return unless previous_submission.is_a?(Hash)

        return unless previous_submission['id'].to_s == params[:id].to_s

        previous_submission['idempotency_token']
      end

      def claim
        @claim ||= Claim.load_from_app_store(params[:id])
      end

      def set_form_session
        multi_step_form_session && session[:multi_step_form_id] = params[:id]
      end

      def clear_stale_submission_session
        previous_submission = session[:payments_last_submission]
        return unless previous_submission.is_a?(Hash)

        previous_id = previous_submission['id']
        redirect_to your_nsm_claims_path and return if previous_id.to_s == params[:id].to_s
        return if previous_id.blank?

        session.delete("payments:#{previous_id}")
      end
    end
  end
end
