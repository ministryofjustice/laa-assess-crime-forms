module Payments
  module Steps
    class LinkedClaimSearchController < BaseController
      def new
        set_page_heading
        @form_object = Payments::Steps::LinkedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(search_params)
        @search_form.execute if @search_form.valid?

        render :edit
      end

      def edit
        set_page_heading
        @form_object = Payments::Steps::LinkedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(default_params)
      end

      def update
        update_and_advance(Payments::Steps::LinkedClaimForm, as: :linked_claim_search)
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
        when 'assigned_counsel'
          'non_standard_magistrate'
        when 'assigned_counsel_appeal', 'assigned_counsel_amendment'
          'assigned_counsel'
        end
      end

      def set_page_heading
        @page_heading ||= I18n.t("payments.steps.linked_claim_search.heading_#{linked_request_type}")
      end
    end
  end
end
