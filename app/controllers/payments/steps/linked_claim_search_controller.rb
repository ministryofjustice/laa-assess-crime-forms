module Payments
  module Steps
    class LinkedClaimSearchController < BaseController
      def new
        @form_object = Payments::Steps::LinkedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(search_params)
        @search_form.execute if @search_form.valid?

        render :edit
      end

      def edit
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
          request_type: 'non_standard_magistrate'
        }
      end
    end
  end
end
