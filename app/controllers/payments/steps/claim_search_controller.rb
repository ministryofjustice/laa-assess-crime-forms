module Payments
  module Steps
    class ClaimSearchController < BaseController
      def new
        @form_object = Payments::Steps::SelectedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(search_params)
        @search_form.execute if @search_form.valid?

        render :edit, locals: { page_heading: }
      end

      def edit
        @form_object = Payments::Steps::SelectedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(default_params)

        render :edit, locals: { page_heading: }
      end

      def update
        update_and_advance(Payments::Steps::SelectedClaimForm, as: :claim_search)
      end

      private

      def search_params
        params.expect(
          payments_steps_claim_search_form: [:query,
                                             :sort_by,
                                             :sort_direction]
        ).merge(default_params)
      end

      def default_params
        {
          page: params.fetch(:page, '1'),
          request_type: linked_request_type
        }
      end

      def linked_request_type
        case multi_step_form_session['request_type']
        when 'assigned_counsel', 'non_standard_mag_appeal', 'non_standard_mag_amendment', 'non_standard_mag_supplemental'
          'non_standard_magistrate'
        when 'assigned_counsel_appeal', 'assigned_counsel_amendment'
          'assigned_counsel'
        else
          raise StandardError, "Unknown request type for: #{multi_step_form_session['request_type']}"
        end
      end

      def page_heading
        if multi_step_form_session['request_type'].in?(%w[assigned_counsel non_standard_magistrate])
          I18n.t('payments.steps.claim_search.edit.heading')
        else
          I18n.t("payments.steps.claim_search.edit.heading_#{linked_request_type}")
        end
      end
    end
  end
end
