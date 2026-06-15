module Payments
  module Steps
    module Nsm
      class ClaimDetailsController < BaseController
        def edit
          @form_object = Payments::Steps::Nsm::ClaimDetailForm.build(multi_step_form_session.answers, multi_step_form_session:)
        end

        def update
          store_submission_date
          update_and_advance(Payments::Steps::Nsm::ClaimDetailForm, as: :nsm_claim_details)
        end

        private

        def form_key
          'payments_steps_nsm_claim_detail_form'
        end

        def store_submission_date
          return unless submission_date_present?

          # rubocop:disable Rails/StrongParametersExpect
          params[form_key]['original_submission_year'] = submission_year
          params[form_key]['original_submission_month'] = submission_month
          # rubocop:enable Rails/StrongParametersExpect
        end

        def submission_date_present?
          submission_year.present? && submission_month.present?
        end

        def submission_year
          params.dig(form_key, 'original_submission_date(1i)')
        end

        def submission_month
          params.dig(form_key, 'original_submission_date(2i)')
        end
      end
    end
  end
end
