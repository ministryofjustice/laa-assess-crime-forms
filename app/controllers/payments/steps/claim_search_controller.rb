module Payments
  module Steps
    class ClaimSearchController < BaseController
      before_action :clear_session_payment, only: [:update], if: -> { params[:new_record].present? }

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
        if params[:new_record].present?
          clear_session_payment
          redirect_to edit_payments_steps_office_code_search_path
        else
          update_and_advance(Payments::Steps::SelectedClaimForm, as: :claim_search)
        end
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
          request_type: linked_request_type,
          claim_type: multi_step_form_session['request_type']
        }
      end

      def linked_request_type
        case multi_step_form_session['request_type']
        when 'assigned_counsel', 'non_standard_mag_appeal', 'non_standard_mag_amendment', 'non_standard_mag_supplemental'
          'non_standard_magistrate'
        when 'assigned_counsel_appeal', 'assigned_counsel_amendment'
          'assigned_counsel'
        # :nocov:
        else
          raise StandardError, "Unknown request type for: #{multi_step_form_session['request_type']}"
        end
        # :nocov:
      end

      def page_heading
        I18n.t("payments.steps.claim_search.edit.heading_#{linked_request_type}")
      end

      def clear_session_payment
        request_type = multi_step_form_session['request_type']
        multi_step_form_session.reset_answers
        multi_step_form_session['request_type'] = request_type
      end
    end
  end
end
